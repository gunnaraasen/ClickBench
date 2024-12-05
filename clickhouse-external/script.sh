#!/bin/bash

# export RESULTDIR=...

echo "Running the benchmark"

./benchmark.sh 2>&1 | tee "${RESULTDIR}"/clickhouse.log

echo "Benchmark done"