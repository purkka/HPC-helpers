# Simple MPI/OpenMP Hybrid Software

## Compiling

```bash
mpicc -fopenmp simple-hybrid.c -o simple-hybrid
```

## Running

```bash
env OMP_NUM_THREADS=8 mpirun --bind-to none -n 2 simple-hybrid
```
