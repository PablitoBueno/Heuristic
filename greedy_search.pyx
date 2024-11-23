# -*- coding: utf-8 -*-
from heapq import heappush, heappop
from typing import List, Dict, Tuple

# Definindo a estrutura de um nó
class Node:
    def __init__(self, name: str, heuristic: float):
        self.name = name
        self.heuristic = heuristic

    def __lt__(self, other):
        # Comparação para a fila de prioridade (menor heurística tem prioridade)
        return self.heuristic < other.heuristic

# Função para a busca gulosa
def greedy_search(Graph: Dict[str, List[str]], heuristics: Dict[str, float], start: str, goal: str) -> List[str]:
    # Inicializando a fila de prioridade
    open_list = []
    heappush(open_list, Node(start, heuristics[start]))

    # Inicializando o conjunto de nós visitados
    visited = set()
    came_from = {}

    while open_list:
        # Pega o nó com a menor heurística
        current_node = heappop(open_list)
        current_name = current_node.name

        # Se encontramos o objetivo, reconstruímos o caminho
        if current_name == goal:
            path = []
            while current_name in came_from:
                path.append(current_name)
                current_name = came_from[current_name]
            path.append(start)
            return path[::-1]  # Retorna o caminho invertido

        # Marca o nó como visitado
        visited.add(current_name)

        # Explora os vizinhos
        for neighbor in Graph.get(current_name, []):
            if neighbor not in visited:
                # Adiciona o vizinho à fila de prioridade
                heappush(open_list, Node(neighbor, heuristics[neighbor]))
                # Registra de onde viemos
                if neighbor not in came_from:
                    came_from[neighbor] = current_name

    # Se não encontrar um caminho
    return []

# Exemplo de uso
if __name__ == "__main__":
    # Definindo um grafo simples
    graph = {
        'A': ['B', 'C'],
        'B': ['A', 'D', 'E'],
        'C': ['A', 'F'],
        'D': ['B'],
        'E': ['B'],
        'F': ['C']
    }

    # Heurísticas para cada nó
    heuristics = {
        'A': 6,
        'B': 2,
        'C': 1,
        'D': 3,
        'E': 5,
        'F': 0
    }

    # Executando a busca gulosa
    start_node = 'A'
    goal_node = 'F'
    path = greedy_search(graph, heuristics, start_node, goal_node)
    print(f"Caminho encontrado: {path}")
