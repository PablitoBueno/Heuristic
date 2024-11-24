# -*- coding: utf-8 -*-
# cython: language_level=3

# Defining the necessary dependencies
from typing import Tuple

# Node class representing the nodes of the graph
cdef class Node:
    cdef public str name
    cdef public float heuristic

    def __init__(self, name, heuristic):
        self.name = name
        self.heuristic = heuristic

    def __lt__(self, other):
        # Comparing nodes based on heuristic value
        return self.heuristic < other.heuristic

def hill_climbing(dict graph, dict heuristics, str start, str goal):
    """
    Hill Climbing algorithm for graphs.
    :param graph: Dictionary representing the graph of nodes and their connections.
    :param heuristics: Dictionary containing the heuristics of the nodes.
    :param start: Starting node.
    :param goal: Goal node.
    :return: Path of nodes to the goal and the final heuristic value.
    """
    cdef Node current_node = Node(start, heuristics[start])
    current_node.heuristic = heuristics[start]
    
    cdef list path = [current_node.name]  # Fixed from List to list
    cdef set visited = set([current_node.name])

    while current_node.name != goal:
        best_score = float('-inf')
        best_neighbor = None

        # Explore neighbors
        for neighbor in graph.get(current_node.name, []):
            if neighbor not in visited:
                visited.add(neighbor)
                neighbor_heuristic = heuristics[neighbor]
                if neighbor_heuristic > best_score:
                    best_score = neighbor_heuristic
                    best_neighbor = neighbor

        # If no improvement is found, terminate the algorithm
        if best_neighbor is None:
            break

        current_node = Node(best_neighbor, best_score)
        path.append(best_neighbor)

    return path, heuristics[current_node.name]
