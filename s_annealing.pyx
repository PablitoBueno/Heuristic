# distutils: language = c++
# cython: language_level = 3

from libc.math cimport exp
import random

cdef class SimulatedAnnealing:
    cdef object objective_function  # Função objetivo
    cdef object neighbor_function  # Função para gerar vizinhos
    cdef list initial_solution
    cdef double temperature
    cdef double cooling_rate
    cdef double min_temperature
    cdef int max_iterations
    cdef int max_no_improve
    cdef int iterations_no_improve

    def __init__(self, 
                 object objective_function, 
                 list initial_solution, 
                 object neighbor_function=None, 
                 double temperature=1000.0, 
                 double cooling_rate=0.99, 
                 double min_temperature=1e-6, 
                 int max_iterations=1000, 
                 int max_no_improve=100):
        """
        :param objective_function: Função objetivo a ser minimizada.
        :param initial_solution: Solução inicial como lista.
        :param neighbor_function: Função para gerar vizinhos. 
                                  Caso None, usa a lógica padrão.
        :param temperature: Temperatura inicial.
        :param cooling_rate: Taxa de resfriamento (0 < cooling_rate < 1).
        :param min_temperature: Temperatura mínima para interromper.
        :param max_iterations: Número máximo de iterações.
        :param max_no_improve: Iterações máximas sem melhora.
        """
        self.objective_function = objective_function
        self.initial_solution = initial_solution
        self.neighbor_function = neighbor_function if neighbor_function is not None else self.default_neighbor
        self.temperature = temperature
        self.cooling_rate = cooling_rate
        self.min_temperature = min_temperature
        self.max_iterations = max_iterations
        self.max_no_improve = max_no_improve
        self.iterations_no_improve = 0

    cpdef list run(self, log_progress=False):
        """
        Executa o algoritmo de Simulated Annealing.
        :param log_progress: Se True, exibe o progresso da solução.
        :return: Melhor solução encontrada e seu valor na função objetivo.
        """
        cdef list current_solution = self.initial_solution[:]
        cdef list best_solution = current_solution[:]
        cdef double current_cost = self.objective_function(current_solution)
        cdef double best_cost = current_cost

        cdef int iteration
        cdef double new_cost, delta, acceptance_probability
        cdef list new_solution

        for iteration in range(self.max_iterations):
            # Gera uma solução vizinha usando a função fornecida pelo usuário
            new_solution = self.neighbor_function(current_solution)
            new_cost = self.objective_function(new_solution)

            # Calcula a variação de custo
            delta = new_cost - current_cost

            # Aceita a solução com base na probabilidade
            if delta < 0 or random.uniform(0, 1) < exp(-delta / self.temperature):
                current_solution = new_solution[:]
                current_cost = new_cost

                # Atualiza a melhor solução
                if current_cost < best_cost:
                    best_solution = current_solution[:]
                    best_cost = current_cost
                    self.iterations_no_improve = 0  # Reset no contador de não melhorias
                else:
                    self.iterations_no_improve += 1

            # Resfria a temperatura
            self.temperature *= self.cooling_rate

            # Logging opcional
            if log_progress and iteration % 100 == 0:
                print(f"Iteração {iteration}: Melhor custo = {best_cost}")

            # Condições de parada
            if self.temperature < self.min_temperature or self.iterations_no_improve > self.max_no_improve:
                break

        return [best_solution, best_cost]

    cdef list default_neighbor(self, list solution):
        """
        Gera uma solução vizinha padrão, alterando levemente os valores.
        :param solution: Solução atual.
        :return: Solução vizinha.
        """
        cdef list neighbor = solution[:]
        cdef int i = random.randint(0, len(solution) - 1)
        cdef double perturbation = random.uniform(-0.1, 0.1)  # Ajuste da magnitude da perturbação
        neighbor[i] += perturbation
        return neighbor
