# distutils: language = c++
# cython: language_level = 3

from libc.math cimport exp
import random

# Simulated Annealing algorithm class
cdef class SimulatedAnnealing:
    cdef object objective_function  # Objective function
    cdef object neighbor_function  # Function to generate neighbors
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
        :param objective_function: Objective function to be minimized.
        :param initial_solution: Initial solution as a list.
        :param neighbor_function: Function to generate neighbors. 
                                  If None, uses the default neighbor logic.
        :param temperature: Initial temperature.
        :param cooling_rate: Cooling rate (0 < cooling_rate < 1).
        :param min_temperature: Minimum temperature to stop the algorithm.
        :param max_iterations: Maximum number of iterations.
        :param max_no_improve: Maximum iterations without improvement.
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
        Executes the Simulated Annealing algorithm.
        :param log_progress: If True, displays the progress of the solution.
        :return: Best solution found and its value from the objective function.
        """
        cdef list current_solution = self.initial_solution[:]
        cdef list best_solution = current_solution[:]
        cdef double current_cost = self.objective_function(current_solution)
        cdef double best_cost = current_cost

        cdef int iteration
        cdef double new_cost, delta, acceptance_probability
        cdef list new_solution

        for iteration in range(self.max_iterations):
            # Generate a neighbor solution using the user-provided function
            new_solution = self.neighbor_function(current_solution)
            new_cost = self.objective_function(new_solution)

            # Calculate the cost difference
            delta = new_cost - current_cost

            # Accept the solution based on the probability
            if delta < 0 or random.uniform(0, 1) < exp(-delta / self.temperature):
                current_solution = new_solution[:]
                current_cost = new_cost

                # Update the best solution
                if current_cost < best_cost:
                    best_solution = current_solution[:]
                    best_cost = current_cost
                    self.iterations_no_improve = 0  # Reset the no improvement counter
                else:
                    self.iterations_no_improve += 1

            # Cool down the temperature
            self.temperature *= self.cooling_rate

            # Optional logging
            if log_progress and iteration % 100 == 0:
                print(f"Iteration {iteration}: Best cost = {best_cost}")

            # Stop conditions
            if self.temperature < self.min_temperature or self.iterations_no_improve > self.max_no_improve:
                break

        return [best_solution, best_cost]

    cdef list default_neighbor(self, list solution):
        """
        Generates a default neighbor solution by slightly altering the values.
        :param solution: Current solution.
        :return: Neighboring solution.
        """
        cdef list neighbor = solution[:]
        cdef int i = random.randint(0, len(solution) - 1)
        cdef double perturbation = random.uniform(-0.1, 0.1)  # Magnitude of the perturbation
        neighbor[i] += perturbation
        return neighbor
