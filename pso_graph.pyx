import numpy as np
cimport numpy as np
from libc.stdlib cimport rand, srand, RAND_MAX
from libc.math cimport fabs

# Function to calculate the cost of a path
cdef double calculate_cost(np.ndarray[np.float64_t, ndim=2] graph, list path):
    """
    Calculates the cost of a path in the graph.
    """
    cdef int i
    cdef double cost = 0.0
    cdef int num_nodes = graph.shape[0]

    if len(path) < 2:
        raise ValueError("The path must have at least two nodes.")
    
    for i in range(len(path) - 1):
        if path[i] < 0 or path[i] >= num_nodes or path[i + 1] < 0 or path[i + 1] >= num_nodes:
            raise ValueError(f"Invalid index in the path: {path}")
        cost += graph[path[i], path[i + 1]]
    return cost

# Function to generate a random path
cdef list generate_random_path(int num_nodes):
    cdef list path = list(range(num_nodes))
    np.random.shuffle(path)
    return path

# Function to swap elements at two positions in a list
cdef void swap(list path, int i, int j):
    cdef int temp = path[i]
    path[i] = path[j]
    path[j] = temp

# Function to update a particle (path) based on best solutions
cdef list update_velocity(np.ndarray[np.float64_t, ndim=2] graph, list current_path, 
                          list personal_best_path, list global_best_path, double w, double c1, double c2):
    cdef list velocity = current_path[:]
    cdef double r1, r2
    cdef int i, j, swap_index

    # Random parameters
    r1 = rand() / RAND_MAX
    r2 = rand() / RAND_MAX
    
    # Update the particle (path) based on the influence of personal and global best paths
    for i in range(len(current_path)):
        if rand() / RAND_MAX < w:
            # Keep the current position with a probability inverse to parameter w
            continue
        else:
            # Influence of the personal best path (swap two elements)
            if rand() / RAND_MAX < c1:
                swap_index = int(r1 * len(current_path))
                swap(current_path, i, swap_index)

            # Influence of the global best path (swap two elements)
            if rand() / RAND_MAX < c2:
                swap_index = int(r2 * len(current_path))
                swap(current_path, i, swap_index)

    return current_path

# PSO function to optimize the path
def pso_graph(np.ndarray[np.float64_t, ndim=2] graph, int num_particles=30, int max_iter=100, 
              double w=0.5, double c1=2.0, double c2=2.0):
    """
    Implements the PSO algorithm for graph search, optimizing the path.
    """
    cdef int num_nodes = graph.shape[0]
    cdef list particles = []
    cdef list personal_best_paths = []
    cdef np.ndarray[np.float64_t, ndim=1] personal_best_scores = np.full(num_particles, np.inf, dtype=np.float64)
    cdef list global_best_path = []
    cdef double global_best_score = float('inf')

    cdef int t, i
    cdef double r1, r2

    # Initialize particles
    for i in range(num_particles):
        path = generate_random_path(num_nodes)
        particles.append(path)
        personal_best_paths.append(path[:])
        personal_best_scores[i] = calculate_cost(graph, path)
        if personal_best_scores[i] < global_best_score:
            global_best_score = personal_best_scores[i]
            global_best_path = path[:]

    # Optimization loop
    for t in range(max_iter):
        # Early stopping criterion (if the solution does not improve in recent iterations)
        if global_best_score < 1e-6:  # Adjustable convergence criterion
            print(f"Convergence reached at iteration {t}.")
            break
        
        for i in range(num_particles):
            # Update the particle based on velocity
            particles[i] = update_velocity(graph, particles[i], personal_best_paths[i], global_best_path, w, c1, c2)

            # Evaluate the new path
            cost = calculate_cost(graph, particles[i])
            if cost < personal_best_scores[i]:
                personal_best_scores[i] = cost
                personal_best_paths[i] = particles[i][:]  # Update personal best path
                if cost < global_best_score:
                    global_best_score = cost
                    global_best_path = particles[i][:]  # Update global best path

        # Dynamic adjustment of w, c1, and c2
        w = max(0.4, w - 0.01)  # Decrease inertia
        c1 = min(2.5, c1 + 0.1)  # Increase personal influence
        c2 = min(2.5, c2 + 0.1)  # Increase global influence

    return global_best_path, global_best_score
