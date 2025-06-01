import pandas as pd
import matplotlib.pyplot as plt
import sys
import math

# read file from CLI
if len(sys.argv) < 2:
    print("Usage: python plotter.py <csv_file>")
    sys.exit(1)

input = sys.argv[1]
df = pd.read_csv(input)

omp_threads = df["OpenMP threads"]
wall_time = df["wall-clock time (s)"]
cpu_utilized = df["CPU utilized (s)"]
memory = df["memory utilized"].str.extract(r"([\d.]+)").astype(float)[0]

xticks = (256 / omp_threads).astype(int)

overtime_start = len(df)


plt.figure(figsize=(6.5, 7.5))

# Wall-clock time
ax1 = plt.subplot(3, 1, 1)
ax1.plot(xticks, wall_time, marker='o', color="tab:blue", label="Wall-clock time")
ax1.set_xscale("log", base=2)
ax1.set_xticks(xticks)
ax1.set_xticklabels(xticks)
ax1.set_ylabel("Time (s)")
ax1.set_xlabel("MPI tasks")
sa1 = ax1.secondary_xaxis(location=1)
sa1.set_xticks(xticks, labels=omp_threads)
sa1.set_xlabel("OpenMP threads")
ax1.legend()
ax1.grid(True)
ax1.set_ylim(bottom=0)

# CPU utilized
ax2 = plt.subplot(3, 1, 2)
ax2.plot(xticks, cpu_utilized, marker='o', color="green", label="CPU utilized")
ax2.set_xscale("log", base=2)
ax2.set_xticks(xticks)
ax2.set_xticklabels(xticks)
ax2.set_ylabel("CPU Time (s)")
ax2.set_xlabel("MPI tasks")
sa2 = ax2.secondary_xaxis(location=1)
sa2.set_xticks(xticks, labels=omp_threads)
sa2.set_xlabel("OpenMP threads")
ax2.legend()
ax2.grid(True)
ax2.set_ylim(bottom=0)

# Memory usage
ax3 = plt.subplot(3, 1, 3)
ax3.plot(xticks, memory, marker='o', color="orange", label="Memory usage")
ax3.set_xscale("log", base=2)
ax3.set_xticks(xticks)
ax3.set_xticklabels(xticks)
ax3.set_ylabel("Memory (GB)")
ax3.set_xlabel("MPI tasks")
sa3 = ax3.secondary_xaxis(location=1)
sa3.set_xticks(xticks, labels=omp_threads)
sa3.set_xlabel("OpenMP threads")
ax3.legend()
ax3.grid(True)
ax3.set_ylim(bottom=0)

plt.tight_layout()
plt.show()
# plt.savefig(f"{input[:-4]}.png")
