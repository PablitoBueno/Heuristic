# -*- coding: utf-8 -*-
from heapq import heappush, heappop
from typing import List, Dict, Tuple

# Defining the structure of a Node
class Node:
    def __init__(self, name: str, heuristic: float):
        self.name = name
        self.heuristic = heuristic

    def __lt__(self, other):
        # Comparison for the priority queue (lower heuristic has higher priority)
        return self.heuristic < other.heuristic

# Greedy search function
def greedy_search(Graph: Dict[str, List[str]], heuristics: Dict[str, float], start: str, goal: str) -> List[str]:
    # Initialize the priority queue
    open_list = []
    heappush(open_list, Node(start, heuristics[start]))

    # Initialize the visited set and came_from dictionary
    visited = set()
    came_from = {}

    while open_list:
        # Pop the node with the smallest heuristic
        current_node = heappop(open_list)
        current_name = current_node.name

        # If the goal is found, reconstruct the path
        if current_name == goal:
            path = []
            while current_name in came_from:
                path.append(current_name)
                current_name = came_from[current_name]
            path.append(start)
            return path[::-1]  # Return the reversed path

        # Mark the node as visited
        visited.add(current_name)

        # Explore neighbors
        for neighbor in Graph.get(current_name, []):
            if neighbor not in visited:
                # Add the neighbor to the priority queue
                heappush(open_list, Node(neighbor, heuristics[neighbor]))
                # Record where we came from
                if neighbor not in came_from:
                    came_from[neighbor] = current_name

    # If no path is found
    return []
