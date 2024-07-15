#!/bin/bash


# export TELEGRAF_PATH=...
# export INFLUXCTL_PATH=...
# export HOST=...
# export TOKEN=...
# export DATABASE=...
# export RESULTDIR=...
# export FILENAME=...

echo "Running the benchmark"

# Import the data

wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.csv.gz'
gzip -d hits.csv.gz
cat <<'EOF' > telegraf-clickbench.conf
[[inputs.file]]
  files = ["hits.csv"]
  data_format = "csv"
  csv_header_row_count = 0
  csv_column_names = []
  csv_column_types = []
  csv_skip_rows = 0
  csv_metadata_rows = 0
  csv_metadata_separators = [":", "="]
  csv_metadata_trim_set = ""
  csv_skip_columns = 0
  csv_delimiter = ","
  csv_comment = ""
  csv_trim_space = false
  csv_tag_columns = []
  csv_measurement_column = ""
  csv_timestamp_column = ""
  csv_timestamp_format = ""
  csv_timezone = ""
  csv_skip_values = []
  csv_skip_errors = false
  csv_reset_mode = "none"

[[outputs.influxdb_v2]]
  urls = ["$HOST"]
  bucket = "$DATABASE"
  token = "$TOKEN"
  content_encoding = "gzip"
EOF

# [[inputs.http]]
#   urls = ["https://datasets.clickhouse.com/hits_compatible/hits.csv.gz"]
#   content_encoding = "gzip"
#   data_format = "csv"

HOST=${HOST} TOKEN=${TOKEN} DATABASE=${DATABASE} start-stop-daemon --start \
    --background \
    --no-close \
    --pidfile telegraf-clickbench.pid \
    --exec $TELEGRAF_PATH \
    -- --config telegraf-clickbench.conf \
        --pidfile telegraf-clickbench.pid > telegraf-clickbench.log 2>&1

sleep 60

start-stop-daemon --stop --oknodo --pidfile telegraf-clickbench.pid

echo "Import data done"

echo "Running the queries"

# Run the queries
./run.sh 2>&1 | tee "${RESULTDIR}/${FILENAME}.log"

cat $RESULTDIR/$FILENAME.log
# rm hits.csv.gz


echo "Benchmark done"