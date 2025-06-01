#include <limits.h>
#include <mpi.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned long long ullong;

int main(int argc, char **argv) {
	int rank, size;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	// Scatter
	int *send_arr = NULL;
	int recv_arr;
	if (rank == 0)
		send_arr = calloc(size, sizeof(int));
	MPI_Scatter(send_arr, 1, MPI_INT, &recv_arr, 1, MPI_INT, 0,
		    MPI_COMM_WORLD);

	// Note that the processes ignore recv_arr. Instead, they run this loop
	// that enables easy inspecting of the threads in htop
#pragma omp parallel for
	for (ullong i = 0; i < ULLONG_MAX; i++) {
		if (i % (1ULL << 32) == 0) {
			printf("Rank %d, thread %d: %llu\n", rank,
			       omp_get_thread_num(), i);
		}
	}

	// Gather
	int send_val = 0;
	int *recv_arr_gather = NULL;
	if (rank == 0)
		recv_arr_gather = calloc(size, sizeof(int));
	MPI_Gather(&send_val, 1, MPI_INT, recv_arr_gather, 1, MPI_INT, 0,
		   MPI_COMM_WORLD);

	if (rank == 0) {
		free(send_arr);
		free(recv_arr_gather);
	}

	MPI_Finalize();
	return 0;
}
