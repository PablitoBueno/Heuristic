# -*- coding: utf-8 -*-
# cython: language_level=3

# Definindo as dependências necessárias
from typing import Tuple

# Classe Node representando os nós do grafo
cdef class Node:
    cdef public str name
    cdef public float heuristic

    def __init__(self, name, heuristic):
        self.name = name
        self.heuristic = heuristic

    def __lt__(self, other):
        return self.heuristic < other.heuristic

def hill_climbing(dict graph, dict heuristics, str start, str goal):
    """
    Algoritmo de Hill Climbing para grafos.
    :param graph: Dicionário representando o grafo de nós e suas conexões.
    :param heuristics: Dicionário contendo as heurísticas dos nós.
    :param start: Nó de partida.
    :param goal: Nó objetivo.
    :return: Caminho de nós até o objetivo e o valor da heurística final.
    """
    cdef Node current_node = Node(start, heuristics[start])
    current_node.heuristic = heuristics[start]
    
    cdef list path = [current_node.name]  # Corrigido de List para list
    cdef set visited = set([current_node.name])

    while current_node.name != goal:
        best_score = float('-inf')
        best_neighbor = None

        # Explorar os vizinhos
        for neighbor in graph.get(current_node.name, []):
            if neighbor not in visited:
                visited.add(neighbor)
                neighbor_heuristic = heuristics[neighbor]
                if neighbor_heuristic > best_score:
                    best_score = neighbor_heuristic
                    best_neighbor = neighbor

        # Se não houver melhorias, encerra o algoritmo
        if best_neighbor is None:
            break

        current_node = Node(best_neighbor, best_score)
        path.append(best_neighbor)

    return path, heuristics[current_node.name]
