#!/bin/bash


# export HOST=...
# export PGPASSWORD=...
# export DATABASE=...

echo 1
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "CREATE EXTENSION IF NOT EXISTS timescaledb"

# Import the data
echo 2

wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
gzip -d hits.tsv.gz
sudo chmod og+rX ~
chmod 777 hits.tsv

echo 3
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" < create.sql
echo 4
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "SELECT create_hypertable('hits', 'eventtime')"
echo 5
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "CREATE INDEX ix_counterid ON hits (counterid)"
echo 6
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "ALTER TABLE hits SET (timescaledb.compress, timescaledb.compress_orderby = 'counterid, eventdate, userid, eventtime')"
echo 7
psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "SELECT add_compression_policy('hits', INTERVAL '1s')"
echo 8

psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -t -c '\timing' -c "\\copy hits FROM 'hits.tsv'"
echo 9

# 1619875.288 ms (26:59.875)

# See https://github.com/timescale/timescaledb/issues/4473#issuecomment-1167095245
# https://docs.timescale.com/timescaledb/latest/how-to-guides/compression/manually-compress-chunks/#compress-chunks-manually
# TimescaleDB benchmark wihout compression is available in timescaledb directory

time psql -u postgres -h "$HOST" -p 9001 "sslmode=require" -d "$DATABASE" -c "SELECT compress_chunk(i, if_not_compressed => true) FROM show_chunks('hits') i"
echo 10

# 49m45.120s

./run.sh 2>&1 | tee log.txt
echo 11

sudo du -bcs /var/lib/postgresql/14/main/

cat log.txt | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'
