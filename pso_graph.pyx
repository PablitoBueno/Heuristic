import numpy as np
cimport numpy as np
from libc.stdlib cimport rand, srand, RAND_MAX
from libc.math cimport fabs

# Função para calcular o custo de um caminho
cdef double calculate_cost(np.ndarray[np.float64_t, ndim=2] graph, list path):
    """
    Calcula o custo de um caminho no grafo.
    """
    cdef int i
    cdef double cost = 0.0
    cdef int num_nodes = graph.shape[0]

    if len(path) < 2:
        raise ValueError("O caminho precisa ter pelo menos dois nós.")
    
    for i in range(len(path) - 1):
        if path[i] < 0 or path[i] >= num_nodes or path[i + 1] < 0 or path[i + 1] >= num_nodes:
            raise ValueError(f"Índice inválido no caminho: {path}")
        cost += graph[path[i], path[i + 1]]
    return cost

# Função para gerar um caminho aleatório
cdef list generate_random_path(int num_nodes):
    cdef list path = list(range(num_nodes))
    np.random.shuffle(path)
    return path

# Função para trocar elementos em duas posições de uma lista
cdef void swap(list path, int i, int j):
    cdef int temp = path[i]
    path[i] = path[j]
    path[j] = temp

# Função para atualizar a partícula (caminho) com base nas melhores soluções
cdef list update_velocity(np.ndarray[np.float64_t, ndim=2] graph, list current_path, 
                          list personal_best_path, list global_best_path, double w, double c1, double c2):
    cdef list velocity = current_path[:]
    cdef double r1, r2
    cdef int i, j, swap_index

    # Parâmetros aleatórios
    r1 = rand() / RAND_MAX
    r2 = rand() / RAND_MAX
    
    # Atualização da partícula (caminho) com base na influência do melhor pessoal e global
    for i in range(len(current_path)):
        if rand() / RAND_MAX < w:
            # Mantém a posição atual com probabilidade inversa ao parâmetro w
            continue
        else:
            # Influência do melhor caminho pessoal (swap de dois elementos)
            if rand() / RAND_MAX < c1:
                swap_index = int(r1 * len(current_path))
                swap(current_path, i, swap_index)

            # Influência do melhor caminho global (swap de dois elementos)
            if rand() / RAND_MAX < c2:
                swap_index = int(r2 * len(current_path))
                swap(current_path, i, swap_index)

    return current_path

# Função de PSO para otimização do caminho
def pso_graph(np.ndarray[np.float64_t, ndim=2] graph, int num_particles=30, int max_iter=100, 
              double w=0.5, double c1=2.0, double c2=2.0):
    """
    Implementa o algoritmo PSO para busca em grafos, otimizando o caminho.
    """
    cdef int num_nodes = graph.shape[0]
    cdef list particles = []
    cdef list personal_best_paths = []
    cdef np.ndarray[np.float64_t, ndim=1] personal_best_scores = np.full(num_particles, np.inf, dtype=np.float64)
    cdef list global_best_path = []
    cdef double global_best_score = float('inf')

    cdef int t, i
    cdef double r1, r2

    # Inicialização das partículas
    for i in range(num_particles):
        path = generate_random_path(num_nodes)
        particles.append(path)
        personal_best_paths.append(path[:])
        personal_best_scores[i] = calculate_cost(graph, path)
        if personal_best_scores[i] < global_best_score:
            global_best_score = personal_best_scores[i]
            global_best_path = path[:]

    # Loop de otimização
    for t in range(max_iter):
        # Critério de parada antecipada (se a solução não melhorar nas últimas iterações)
        if global_best_score < 1e-6:  # Critério de convergência ajustável
            print(f"Convergência atingida na iteração {t}.")
            break
        
        for i in range(num_particles):
            # Atualiza a partícula com base na velocidade
            particles[i] = update_velocity(graph, particles[i], personal_best_paths[i], global_best_path, w, c1, c2)

            # Avaliação do novo caminho
            cost = calculate_cost(graph, particles[i])
            if cost < personal_best_scores[i]:
                personal_best_scores[i] = cost
                personal_best_paths[i] = particles[i][:]  # Atualiza o melhor caminho pessoal
                if cost < global_best_score:
                    global_best_score = cost
                    global_best_path = particles[i][:]  # Atualiza o melhor caminho global

        # Ajuste dinâmico de w, c1 e c2
        w = max(0.4, w - 0.01)  # Reduz a inércia
        c1 = min(2.5, c1 + 0.1)  # Aumenta a influência pessoal
        c2 = min(2.5, c2 + 0.1)  # Aumenta a influência global

    return global_best_path, global_best_score
