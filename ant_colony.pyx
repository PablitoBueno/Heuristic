# distutils: language = c++
# cython: language_level = 3

import random
from math import pow

cdef class Ant:
    cdef list visited
    cdef int start_node
    cdef int current_node
    cdef float path_cost
    cdef list path

    def __init__(self, int start_node):
        self.start_node = start_node
        self.current_node = start_node
        self.visited = [start_node]
        self.path_cost = 0.0
        self.path = [start_node]

    def visit(self, int next_node, float distance):
        self.visited.append(next_node)
        self.path.append(next_node)
        self.current_node = next_node
        self.path_cost += distance

    def has_visited(self, int node) -> bool:
        return node in self.visited

    def complete_cycle(self, float distance):
        self.path_cost += distance
        self.path.append(self.start_node)

cdef class ACO:
    cdef int n_nodes
    cdef list distance_matrix
    cdef list pheromone_matrix
    cdef float alpha
    cdef float beta
    cdef float evaporation_rate
    cdef float q

    def __init__(self, list distance_matrix, float alpha=1.0, float beta=2.0, float evaporation_rate=0.5, float q=100.0):
        self.distance_matrix = distance_matrix
        self.n_nodes = len(distance_matrix)
        self.alpha = alpha
        self.beta = beta
        self.evaporation_rate = evaporation_rate
        self.q = q
        self.pheromone_matrix = [[1.0 for _ in range(self.n_nodes)] for _ in range(self.n_nodes)]

    cpdef list run(self, int n_ants, int iterations):
        best_path = []
        best_cost = float('inf')

        for _ in range(iterations):
            ants = [Ant(start_node=random.randint(0, self.n_nodes - 1)) for _ in range(n_ants)]

            for ant in ants:
                for _ in range(self.n_nodes - 1):
                    next_node = self.select_next_node(ant)
                    distance = self.distance_matrix[ant.current_node][next_node]
                    ant.visit(next_node, distance)

                # Complete the cycle
                ant.complete_cycle(self.distance_matrix[ant.current_node][ant.start_node])

                # Update best solution
                if ant.path_cost < best_cost:
                    best_cost = ant.path_cost
                    best_path = ant.path[:]

            # Update pheromone
            self.update_pheromone(ants)

        return [best_path, best_cost]

    cdef int select_next_node(self, Ant ant):
        cdef list probabilities = []
        cdef int current_node = ant.current_node

        for i in range(self.n_nodes):
            if not ant.has_visited(i):
                pheromone = self.pheromone_matrix[current_node][i]
                heuristic = 1.0 / self.distance_matrix[current_node][i] if self.distance_matrix[current_node][i] > 0 else 0
                probabilities.append((i, pow(pheromone, self.alpha) * pow(heuristic, self.beta)))

        total_prob = sum(prob for _, prob in probabilities)
        r = random.uniform(0, total_prob)
        cumulative = 0.0

        for node, prob in probabilities:
            cumulative += prob
            if cumulative >= r:
                return node

    cdef void update_pheromone(self, list ants):
        # Evaporate pheromone
        for i in range(self.n_nodes):
            for j in range(self.n_nodes):
                self.pheromone_matrix[i][j] *= (1 - self.evaporation_rate)

        # Deposit pheromone
        for ant in ants:
            pheromone_contribution = self.q / ant.path_cost
            for i in range(len(ant.path) - 1):
                self.pheromone_matrix[ant.path[i]][ant.path[i + 1]] += pheromone_contribution
