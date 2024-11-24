Heuristic Algorithms Library in Cython

This is a Cython library developed with the goal of applying knowledge in creating libraries, data structures, heuristic algorithms, and Cython. The focus is to provide efficient implementations of techniques such as A* search, greedy search, Hill Climbing, and Simulated Annealing, for the purpose of learning and experimentation. The library uses data structures like nodes and priority queues to optimize the execution of the algorithms.

Implemented Algorithms

1. A (A-Star)*

Implementation of the A* search algorithm to find the shortest path in a graph.

Supports several heuristics: Manhattan, Euclidean, Diagonal.

Allows diagonal movements, depending on the configuration.


Usage Example:

path = a_star(graph, start, end, heuristic="manhattan", allow_diagonals=False)


2. Greedy Search
Greedy search algorithm that expands the node with the smallest heuristic towards the goal.
Implemented using a priority queue (heap).

Usage Example:

path = greedy_search(graph, heuristics, start, goal)


3. Hill Climbing
Hill Climbing algorithm that searches for the best local solution from an initial solution.
Uses heuristics to guide the exploration of neighbors.

Usage Example:

path, final_heuristic = hill_climbing(graph, heuristics, start, goal)


4. Simulated Annealing
Implementation of the Simulated Annealing algorithm for global optimization.
Capable of escaping local minima and finding global solutions by introducing controlled disturbances through temperature.

Usage Example:

sa = SimulatedAnnealing(objective_function, initial_solution)  
best_solution, best_cost = sa.run()



Dependencies

Cython (required to compile the extensions)

Math (for mathematical functions like exp, sqrt)


How to Use

1. Install the dependencies:

pip install cython


2. Compile the library:

python setup.py build_ext --inplace


3. Use the algorithms in your code, with example usage as described in the above algorithms.


Project Structure

a_star.pyx: Implementation of the A* algorithm.

greedy_search.pyx: Implementation of the greedy search.

hill_climbing.pyx: Implementation of the Hill Climbing algorithm.

s_annealing.pyx: Implementation of the Simulated Annealing algorithm.

Objective
The main goal of this library is to apply knowledge of Cython and heuristic algorithms to efficiently solve optimization problems. The implemented algorithms are easy to use and optimized for performance, allowing usage in learning and development contexts.

How to Contribute
If you want to contribute, feel free to open a pull request or an issue for discussion.

License
This project is licensed under the MIT License - see the LICENSE file for more details.

This README contains information about the implemented algorithms, dependencies, project structure, and examples of how to use the library, all with a focus on learning and applying Cython for heuristic algorithms.

