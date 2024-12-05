#!/bin/bash

# Go to https://clickhouse.cloud/ and create a service.
# To get results for various scale, go to "Actions / Advanced Scaling" and turn the slider of the minimum scale to the right.
# The number of threads is "SELECT value FROM system.settings WHERE name = 'max_threads'".

# Load the data

# export HOST=...
# export USER=...
# export PASSWORD=...
# export DATABASE=...
# export RESULTDIR=...
# export FILENAME=...

cp $HOME/ClickBench/datasets/hits_aa.tsv.gz .
gzip -d hits_aa.tsv.gz

echo "Running the benchmark"

clickhouse-client --host "$HOST" --user "$USER" --password "$PASSWORD" --database "$DATABASE" < create.sql

clickhouse-client --host "$HOST" --user "$USER" --password "$PASSWORD" --database "$DATABASE" --time --query "INSERT INTO hits FORMAT TabSeparated" < hits_aa.tsv

# 343.455

echo "Import data done"

echo "Running the queries"

# Run the queries
./run.sh 2>&1 | tee "${RESULTDIR}/${FILENAME}.log"

cat $RESULTDIR/$FILENAME.log

clickhouse-client --host "$HOST" --user "$USER" --password "$PASSWORD" --database "$DATABASE" --query "SELECT total_bytes FROM system.tables WHERE name = 'hits' AND database = 'default'"

rm hits_aa.tsv.gz
rm hits_aa.tsv

echo "Benchmark done"