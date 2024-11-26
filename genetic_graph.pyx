import random
from libc.math cimport INFINITY

# Graph representation using an adjacency dictionary
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

# Function to calculate the cost of a path
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
        # If the edge is not found, the path is invalid
        if not found:
            return INFINITY  # Invalid path if the edge is not found
    return cost

# Genetic algorithm
def genetic_algorithm(Graph graph, int start, int end, int population_size=50, int generations=100, double mutation_rate=0.1):
    cdef list population = []
    cdef list new_population
    cdef list best_solution = []
    cdef double best_cost = INFINITY
    cdef int i, gen

    # Fitness function
    def fitness(path):
        if path[-1] != end:  # Penalizes paths that do not reach the destination
            return INFINITY
        return path_cost(graph, path)

    # Initial generation (random paths)
    for _ in range(population_size):
        path = [start]
        while path[-1] != end:
            neighbors = graph.get_neighbors(path[-1])
            if not neighbors:  # If it gets stuck, restart from the beginning
                path = [start]
                continue
            # Ensure that the path is not just a direct path between start and end
            next_node = random.choice(neighbors)[0]
            if next_node != end or len(path) > 2:  # Do not add a very short direct path
                path.append(next_node)
        population.append(path)

    # Evolution process
    for gen in range(generations):
        # Evaluate population
        population.sort(key=fitness)

        # Update the best solution
        if fitness(population[0]) < best_cost:
            best_cost = fitness(population[0])
            best_solution = population[0]

        # Selection (elitism and tournament)
        new_population = population[:10]  # Keep the 10 best individuals
        while len(new_population) < population_size:
            p1, p2 = random.choices(population[:20], k=2)
            # Crossover
            if len(p1) > 1 and len(p2) > 1:  # Ensure the paths are long enough
                split = random.randint(1, len(p1) - 1)
                child = p1[:split] + [node for node in p2 if node not in p1]
            else:
                # If the path is too short, return one of the parents
                child = p1 if len(p1) > len(p2) else p2
            # Mutation
            if random.random() < mutation_rate and len(child) > 2:  # Avoid invalid ranges
                idx = random.randint(1, len(child) - 2)
                neighbors = graph.get_neighbors(child[idx])
                if neighbors:
                    child[idx] = random.choice(neighbors)[0]
            new_population.append(child)

        population = new_population

    return best_solution, best_cost
