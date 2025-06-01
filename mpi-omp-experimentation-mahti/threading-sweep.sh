#!/bin/bash

display_help() {
    echo "Usage: $0 [options] <program_binary>"
    echo
    echo "Submit a threading sweep benchmark for hybrid MPI+OpenMP jobs on Mahti."
    echo "Tests thread counts from 1 to 256 (2 sockets × 64 cores × 2 threads)."
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo
    echo "Example:"
    echo "  $0 ./my_program"
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

# check that the program binary is provided and executable
PROG_BIN="$1"
if [[ -z "$PROG_BIN" ]]; then
    echo "Error: No program binary specified."
    display_help
    exit 1
elif [[ ! -x "$PROG_BIN" ]]; then
    echo "Error: '$PROG_BIN' is not executable."
    exit 1
fi

# Mahti CPU layout: 2 sockets × 64 cores × 2 threads = 256 CPUs
THREAD_COUNTS=(1 2 4 8 16 32 64 128 256)

# keep job IDs in a file for analysis later on
JOB_FILE="threading-sweep-jobs.txt"
> "$JOB_FILE"

# dubmit jobs with desired thread sizes
for THREADS in "${THREAD_COUNTS[@]}"; do
    MPI_TASKS=$((256 / THREADS))
    JOB_ID=$(sbatch \
            --partition=medium \
            --nodes=4 \
            --ntasks-per-node=$MPI_TASKS \
            --cpus-per-task=$THREADS \
            --hint=multithread \
            --exclusive \
            job.sh "$PROG_BIN" --openmp-threads "$THREADS" \
        | grep -o -E '[0-9]+')

    echo "Submitted job (${JOB_ID}) with ${THREADS} Slurm CPU allocations/OpenMP threads and ${MPI_TASKS} MPI tasks"

    echo "$THREADS,$JOB_ID" >> "$JOB_FILE"
done

echo "All jobs submitted. Job IDs saved to $JOB_FILE."
