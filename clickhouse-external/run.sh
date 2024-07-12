#!/bin/bash

date +%Y%m%d%H%M%S

TRIES=3
QUERY_NUM=1
cat queries.sql | while read query; do

    echo -n "{\"query\": \""$query"\","
    echo -n "\"runtimes\": ["
    for i in $(seq 1 $TRIES); do
        RES=$(clickhouse-client --host "${FQDN:=localhost}" --user "$USER" --password "${PASSWORD:=}" --database "$DATABASE" --time --format=Null --query="$query" --progress 0 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' 2>&1 ||:)
        [[ "$?" == "0" ]] && echo -n "${RES}" || echo -n "null"
        [[ "$i" != $TRIES ]] && echo -n ", "
    done
    echo "]},"

    QUERY_NUM=$((QUERY_NUM + 1))
done

date +%Y%m%d%H%M%S