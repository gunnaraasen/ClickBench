#!/bin/bash

# Go to https://clickhouse.cloud/ and create a service.
# To get results for various scale, go to "Actions / Advanced Scaling" and turn the slider of the minimum scale to the right.
# The number of threads is "SELECT value FROM system.settings WHERE name = 'max_threads'".

# Load the data

# export FQDN=...
# export USER=...
# export PASSWORD=...
# export DATABASE=...
# export RESULTDIR=...
# export FILENAME=...

echo "Running the benchmark"

clickhouse-client --host "$FQDN" --user "$USER" --password "$PASSWORD" --database "$DATABASE" < create.sql

clickhouse-client --host "$FQDN" --user "$USER" --password "$PASSWORD" --database "$DATABASE" --query "
  INSERT INTO hits SELECT * FROM url('https://clickhouse-public-datasets.s3.amazonaws.com/hits_compatible/hits.tsv.gz')
" --time

# 343.455

# Run the queries
./run.sh 2>&1 | tee -a $RESULTDIR/$FILENAME.log

cat $RESULTDIR/$FILENAME.log

cat $RESULTDIR/$FILENAME.log

clickhouse-client --host "$FQDN" --user "$USER" --password "$PASSWORD" --database "$DATABASE" --query "SELECT total_bytes FROM system.tables WHERE name = 'hits' AND database = 'default'"

echo "Benchmark done"