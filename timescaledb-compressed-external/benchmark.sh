#!/bin/bash


# export HOST=...
# export PGPASSWORD=...
# export DATABASE=...
# export RESULTDIR=...
# export FILENAME=...

echo "Running the benchmark"

psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "CREATE EXTENSION IF NOT EXISTS timescaledb"

# Import the data

wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
gzip -d hits.tsv.gz
sudo chmod og+rX ~
chmod 777 hits.tsv

psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" < create.sql
psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "SELECT create_hypertable('hits', 'eventtime')"
psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "CREATE INDEX ix_counterid ON hits (counterid)"
psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "ALTER TABLE hits SET (timescaledb.compress, timescaledb.compress_orderby = 'counterid, eventdate, userid, eventtime')"
psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "SELECT add_compression_policy('hits', INTERVAL '1s')"

psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -t -c '\timing' -c "\\copy hits FROM 'hits.tsv'"

# 1619875.288 ms (26:59.875)

# See https://github.com/timescale/timescaledb/issues/4473#issuecomment-1167095245
# https://docs.timescale.com/timescaledb/latest/how-to-guides/compression/manually-compress-chunks/#compress-chunks-manually
# TimescaleDB benchmark wihout compression is available in timescaledb directory

# 49m45.120s
time psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -c "SELECT compress_chunk(i, if_not_compressed => true) FROM show_chunks('hits') i"

# Run the queries
./run.sh 2>&1 | tee -a $RESULTDIR/$FILENAME.log

cat $RESULTDIR/$FILENAME.log
rm hits.tsv.gz

echo "Benchmark done"