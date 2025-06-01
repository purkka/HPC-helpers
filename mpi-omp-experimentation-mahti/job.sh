#!/bin/bash
#SBATCH --job-name=mpi-omp-hybrid
#SBATCH --account=<project>
#SBATCH --partition=medium
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=4
#SBATCH -o slurm-out-%j

display_help() {
    echo "Usage: $0 [options] <program_binary>"
    echo
    echo "Run an OpenMP+MPI hybrid job with Slurm on Mahti hosted by CSC."
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -t, --openmp-threads  Set number of OpenMP threads (default: \$SLURM_CPUS_PER_TASK)"
    echo
    echo "Example:"
    echo "  $0 ./my_program -t 4"
    exit 0
}

# default openmp threads
OMP_THREADS=$SLURM_CPUS_PER_TASK

# parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            display_help
            ;;
        -t|--openmp-threads)
            OMP_THREADS="$2"
            shift 2
            ;;
        *)
            # assume the first non-option argument is the program binary
            if [[ -z "$PROG_BIN" ]]; then
                PROG_BIN="$1"
                shift
            else
                echo "Error: Unknown argument or too many arguments: $1"
                exit 1
            fi
            ;;
    esac
done

# check that the program binary is provided and executable
if [[ -z "$PROG_BIN" ]]; then
    echo "Error: No program binary specified."
    display_help
    exit 1
elif [[ ! -x "$PROG_BIN" ]]; then
    echo "Error: '$PROG_BIN' is not executable."
    exit 1
fi

export OMP_NUM_THREADS=OMP_THREADS

# module load ...

srun -n $SLURM_NTASKS "$PROG_BIN"
