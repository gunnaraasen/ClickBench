#!/bin/bash


# export TELEGRAF_PATH=...
# export GO_PATH=...
# export HOST=...
# export TOKEN=...
# export DATABASE=...
# export RESULTDIR=...
# export FILENAME=...

echo "Running the benchmark"

# Import the data
cp $HOME/ClickBench/datasets/hits_aa.csv.gz .
gzip -d hits_aa.csv.gz

cat <<'EOF' > telegraf-clickbench.conf
[agent]
  interval = "2m"
  round_interval = false
  metric_batch_size = 5000
  metric_buffer_limit = 5000000
  collection_jitter = "0s"
  flush_interval = "2m"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = true
[[inputs.file]]
  files = ["$HOME/ClickBench/influxdb3-external/hits_aa.csv"]
  data_format = "csv"
  csv_header_row_count = 0
  csv_column_names = ["WatchID","JavaEnable", "Title", "GoodEvent", "EventTime", "EventDate", "CounterID", "ClientIP", "RegionID", "UserID", "CounterClass", "OS", "UserAgent", "URL", "Referer", "IsRefresh", "RefererCategoryID", "RefererRegionID", "URLCategoryID", "URLRegionID", "ResolutionWidth", "ResolutionHeight", "ResolutionDepth", "FlashMajor", "FlashMinor", "FlashMinor2", "NetMajor", "NetMinor", "UserAgentMajor", "UserAgentMinor", "CookieEnable", "JavascriptEnable", "IsMobile", "MobilePhone", "MobilePhoneModel", "Params", "IPNetworkID", "TraficSourceID", "SearchEngineID", "SearchPhrase", "AdvEngineID", "IsArtifical", "WindowClientWidth", "WindowClientHeight", "ClientTimeZone", "ClientEventTime", "SilverlightVersion1", "SilverlightVersion2", "SilverlightVersion3", "SilverlightVersion4", "PageCharset", "CodeVersion", "IsLink", "IsDownload", "IsNotBounce", "FUniqID", "OriginalURL", "HID", "IsOldCounter", "IsEvent", "IsParameter", "DontCountHits", "WithHash", "HitColor", "LocalEventTime", "Age", "Sex", "Income", "Interests", "Robotness", "RemoteIP", "WindowName", "OpenerName", "HistoryLength", "BrowserLanguage", "BrowserCountry", "SocialNetwork", "SocialAction", "HTTPError", "SendTiming", "DNSTiming", "ConnectTiming", "ResponseStartTiming", "ResponseEndTiming", "FetchTiming", "SocialSourceNetworkID", "SocialSourcePage", "ParamPrice", "ParamOrderID", "ParamCurrency", "ParamCurrencyID", "OpenstatServiceName", "OpenstatCampaignID", "OpenstatAdID", "OpenstatSourceID", "UTMSource", "UTMMedium", "UTMCampaign", "UTMContent", "UTMTerm", "FromTag", "HasGCLID", "RefererHash", "URLHash", "CLID"]
  csv_column_types = ["int", "int", "string", "int", "timestamp", "Date", "int", "int", "int", "int", "int", "int", "int", "string", "string", "int", "int", "int", "int", "int", "int", "int", "int", "int", "int", "string", "int", "int", "int", "string", "int", "int", "int", "int", "string", "string", "int", "int", "int", "string", "int", "int", "int", "int", "int", "timestamp", "int", "int", "int", "int", "string", "int", "int", "int", "int", "int", "string", "int", "int", "int", "int", "int", "int", "string", "timestamp", "int", "int", "int", "int", "int", "int", "int", "int", "int", "string", "string", "string", "string", "int", "int", "int", "int", "int", "int", "int", "int", "string", "int", "string", "string", "int", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "int", "int", "int", "int"]
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
  csv_timestamp_column = "EventTime"
  csv_timestamp_format = "2006-01-02 15:04:05"
  csv_timezone = ""
  csv_skip_values = []
  csv_skip_errors = false
  csv_reset_mode = "none"
  name_override = "hits"

[[outputs.influxdb_v2]]
  urls = ["$HOST"]
  bucket = "$DATABASE"
  token = "$TOKEN"
  content_encoding = "gzip"
EOF

HOST=${HOST} TOKEN=${TOKEN} DATABASE=${DATABASE} start-stop-daemon --start \
    --background \
    --no-close \
    --pidfile ~/ClickBench/influxdb3-external/telegraf-clickbench.pid \
    --exec $TELEGRAF_PATH \
    -- --config ~/ClickBench/influxdb3-external/telegraf-clickbench.conf \
        --pidfile ~/ClickBench/influxdb3-external/telegraf-clickbench.pid > ~/ClickBench/influxdb3-external/telegraf-clickbench.log 2>&1

sleep 240

start-stop-daemon --stop --oknodo --pidfile ~/ClickBench/influxdb3-external/telegraf-clickbench.pid

echo "Import data done"

echo "Running the queries"
$GO_PATH build query.go
# Run the queries
./run.sh 2>&1 | tee "${RESULTDIR}/${FILENAME}.log"

cat $RESULTDIR/$FILENAME.log
rm hits_aa.csv

echo "Benchmark done"