import random
from libc.math cimport INFINITY

# Representação de um grafo usando dicionário de adjacência
cdef class Graph:
    cdef dict adjacency_list

    def __init__(self, edges):
        self.adjacency_list = {}
        for u, v, weight in edges:
            if u not in self.adjacency_list:
                self.adjacency_list[u] = []
            if v not in self.adjacency_list:
                self.adjacency_list[v] = []
            self.adjacency_list[u].append((v, weight))
            self.adjacency_list[v].append((u, weight))

    def get_neighbors(self, node):
        return self.adjacency_list.get(node, [])

# Função para calcular o custo de um caminho
cdef double path_cost(Graph graph, list path):
    cdef double cost = 0
    for i in range(len(path) - 1):
        neighbors = graph.get_neighbors(path[i])
        found = False
        for neighbor, weight in neighbors:
            if neighbor == path[i + 1]:
                cost += weight
                found = True
                break
        # Verifica se a aresta não foi encontrada
        if not found:
            return INFINITY  # Caminho inválido se a aresta não for encontrada
    return cost

# Algoritmo genético
def genetic_algorithm(Graph graph, int start, int end, int population_size=50, int generations=100, double mutation_rate=0.1):
    cdef list population = []
    cdef list new_population
    cdef list best_solution = []
    cdef double best_cost = INFINITY
    cdef int i, gen

    # Função de aptidão
    def fitness(path):
        if path[-1] != end:  # Penaliza caminhos que não chegam ao destino
            return INFINITY
        return path_cost(graph, path)

    # Geração inicial (caminhos aleatórios)
    for _ in range(population_size):
        path = [start]
        while path[-1] != end:
            neighbors = graph.get_neighbors(path[-1])
            if not neighbors:  # Se encalhar, volta ao início
                path = [start]
                continue
            # Garante que não seja apenas um caminho direto entre start e end
            next_node = random.choice(neighbors)[0]
            if next_node != end or len(path) > 2:  # Não adicionar um caminho direto muito curto
                path.append(next_node)
        population.append(path)

    # Evolução
    for gen in range(generations):
        # Avaliar população
        population.sort(key=fitness)

        # Atualiza melhor solução
        if fitness(population[0]) < best_cost:
            best_cost = fitness(population[0])
            best_solution = population[0]

        # Seleção (elitismo e torneio)
        new_population = population[:10]  # Mantém os 10 melhores
        while len(new_population) < population_size:
            p1, p2 = random.choices(population[:20], k=2)
            # Cruzamento (crossover)
            if len(p1) > 1 and len(p2) > 1:  # Certificar que os caminhos são suficientemente longos
                split = random.randint(1, len(p1) - 1)
                child = p1[:split] + [node for node in p2 if node not in p1]
            else:
                # Se o caminho for muito curto, retorna um dos pais
                child = p1 if len(p1) > len(p2) else p2
            # Mutação
            if random.random() < mutation_rate and len(child) > 2:  # Evitar faixas inválidas
                idx = random.randint(1, len(child) - 2)
                neighbors = graph.get_neighbors(child[idx])
                if neighbors:
                    child[idx] = random.choice(neighbors)[0]
            new_population.append(child)

        population = new_population

    return best_solution, best_cost
