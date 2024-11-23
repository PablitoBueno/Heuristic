import cython
from heapq import heappush, heappop
import math

cdef class Node:
    cdef public int x, y              # Torna os atributos acessíveis fora da classe
    cdef public double cost           # Custo acumulado
    cdef public double heuristic      # Heurística (estimativa de custo restante)
    cdef public object parent         # Referência ao nó pai para reconstruir o caminho

    def __init__(self, int x, int y, double cost, double heuristic, object parent=None):
        self.x = x
        self.y = y
        self.cost = cost
        self.heuristic = heuristic
        self.parent = parent

    @cython.locals(other=Node)
    def __lt__(self, other):
        """
        Define a comparação para ordenação no heap com base no custo total (f = g + h).
        """
        return (self.cost + self.heuristic) < (other.cost + other.heuristic)

def a_star(list graph, tuple start, tuple end, str heuristic="manhattan", bint allow_diagonals=False):
    """
    Busca A* aprimorada com heurísticas flexíveis e suporte a movimento diagonal.
    :param graph: Lista de listas representando o grafo.
    :param start: Ponto inicial como (x, y).
    :param end: Ponto final como (x, y).
    :param heuristic: "manhattan", "euclidean" ou "diagonal".
    :param allow_diagonals: Se True, permite movimentação diagonal.
    :return: Caminho mais curto como lista de coordenadas [(x, y), ...].
    """
    cdef int rows = len(graph)
    cdef int cols = len(graph[0])
    cdef list open_set = []
    cdef set closed_set = set()  # Usando set para verificar rapidamente se o nó já foi visitado
    cdef Node start_node = Node(start[0], start[1], 0, 0)
    cdef Node end_node = Node(end[0], end[1], 0, 0)

    heappush(open_set, start_node)

    while open_set:
        current_node = heappop(open_set)

        # Se chegou ao destino, reconstrói o caminho
        if (current_node.x, current_node.y) == (end_node.x, end_node.y):
            return reconstruct_path(current_node)

        # Adiciona o nó atual ao conjunto fechado
        closed_set.add((current_node.x, current_node.y))

        # Expandir vizinhos
        for neighbor in get_neighbors(graph, current_node, end_node, rows, cols, heuristic, allow_diagonals):
            if (neighbor.x, neighbor.y) in closed_set:
                continue

            heappush(open_set, neighbor)

    return []  # Caminho não encontrado

def reconstruct_path(Node current_node):
    path = []
    while current_node:
        path.append((current_node.x, current_node.y))
        current_node = current_node.parent
    return path[::-1]

def get_neighbors(list graph, Node current_node, Node end_node, int rows, int cols, str heuristic, bint allow_diagonals):
    """
    Retorna vizinhos válidos, considerando movimentação diagonal e heurística escolhida.
    """
    cdef list directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    if allow_diagonals:
        directions += [(-1, -1), (-1, 1), (1, -1), (1, 1)]

    neighbors = []
    for dx, dy in directions:
        x, y = current_node.x + dx, current_node.y + dy
        if 0 <= x < rows and 0 <= y < cols:
            cost = graph[x][y]
            heuristic_value = calculate_heuristic(x, y, end_node.x, end_node.y, heuristic)
            neighbors.append(Node(x, y, current_node.cost + cost, heuristic_value, current_node))
    return neighbors

def calculate_heuristic(int x1, int y1, int x2, int y2, str heuristic):
    """
    Calcula a heurística com base na escolha.
    """
    if heuristic == "euclidean":
        return math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)
    elif heuristic == "diagonal":
        return max(abs(x1 - x2), abs(y1 - y2))
    else:  # Manhattan
        return abs(x1 - x2) + abs(y1 - y2)
