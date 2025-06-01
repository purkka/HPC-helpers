#!/bin/bash

display_help() {
    echo "Usage: $0 <job_id_file>"
    echo
    echo "Parse Slurm job efficiency metrics (wall time, CPU usage, memory) from seff"
    echo "and generate a CSV report for threading-sweep benchmarks."
    echo
    echo "Arguments:"
    echo "  <job_id_file>  File containing comma-separated thread counts and job IDs"
    echo "                 (format: 'THREADS,JOB_ID' per line)"
    echo
    echo "Output:"
    echo "  Creates a CSV file named '<job_id_file>_results.csv' with columns:"
    echo "  OpenMP threads,wall-clock time (s),CPU utilized (s),CPU efficiency %,memory utilized"
    echo
    echo "Example:"
    echo "  $0 threading-sweep-jobs.txt"
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

# validate input
JOB_FILE="$1"
if [[ -z "$JOB_FILE" || ! -f "$JOB_FILE" ]]; then
    echo "Error: Missing or invalid job ID file."
    display_help
    exit 1
fi
OUTPUT_CSV="${JOB_FILE%.*}_results.csv"

# header for CSV
echo "OpenMP threads,wall-clock time (s),CPU utilized (s),CPU efficiency %,memory utilized" > "$OUTPUT_CSV"

hms_to_seconds() {
    local input="$1"
    if [[ "$input" =~ ([0-9]+)-([0-9]+):([0-9]+):([0-9]+) ]]; then
        # dd-hh:mm:ss format
        days=${BASH_REMATCH[1]}
        hours=${BASH_REMATCH[2]}
        minutes=${BASH_REMATCH[3]}
        seconds=${BASH_REMATCH[4]}
        echo $((10#$days * 86400 + 10#$hours * 3600 + 10#$minutes * 60 + 10#$seconds))
    elif [[ "$input" =~ ([0-9]+):([0-9]+):([0-9]+) ]]; then
        # hh:mm:ss format
        hours=${BASH_REMATCH[1]}
        minutes=${BASH_REMATCH[2]}
        seconds=${BASH_REMATCH[3]}
        echo $((10#$hours * 3600 + 10#$minutes * 60 + 10#$seconds))
    else
        echo "0"  # fallback/default if parsing fails
    fi
}

while IFS=',' read -r THREADS JOB_ID; do
    SEFF_OUTPUT=$(seff "$JOB_ID")
    WALL_TIME_RAW=$(echo "$SEFF_OUTPUT" | grep "Job Wall-clock time" | awk -F': ' '{print $2}')
    CPU_UTILIZED_RAW=$(echo "$SEFF_OUTPUT" | grep "CPU Utilized" | awk -F': ' '{print $2}')
    CPU_EFFICIENCY=$(echo "$SEFF_OUTPUT" | grep "CPU Efficiency" | grep -oP '\d+\.\d+(?=%)')
    MEMORY=$(echo "$SEFF_OUTPUT" | grep "Memory Utilized" | awk -F: '{print $2}' | xargs)

    if [ -n "$WALL_TIME_RAW" ] && [ -n "$CPU_UTILIZED_RAW" ]; then
        WALL_TIME=$(hms_to_seconds "$WALL_TIME_RAW")
        CPU_UTILIZED=$(hms_to_seconds "$CPU_UTILIZED_RAW")
        echo "${THREADS},${WALL_TIME},${CPU_UTILIZED},${CPU_EFFICIENCY},${MEMORY}" >> "$OUTPUT_CSV"
    else
        echo "${THREADS},ERROR: Could not parse seff output for Job ${JOB_ID}" >> "$OUTPUT_CSV"
    fi
done < "$JOB_FILE"

echo "Results written to ${OUTPUT_CSV}"

