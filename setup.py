from setuptools import setup
from Cython.Build import cythonize

setup(
      ext_modules = cythonize(
        ["a_star.pyx", "greedy_search.pyx","hill_climbing.pyx","s_annealing.pyx","ant_colony.pyx"], language="c++"  # Especifica C++ como o compilador
      )
)
