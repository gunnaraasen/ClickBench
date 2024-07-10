#!/bin/bash

TRIES=3
QUERY_NUM=1

cat queries.sql | while read query; do
    # sync
    # echo 3 | sudo tee /proc/sys/vm/drop_caches

    echo -n "["
    for i in $(seq 1 $TRIES); do
        RES=$(psql -U postgres -h "$HOST" -p 9001 -d "$DATABASE" -t -c '\timing' -c "$query" | grep 'Time' 2>&1 ||:)
        [[ "$?" == "0" ]] && echo -n "${RES}" || echo -n "null"
        [[ "$i" != $TRIES ]] && echo -n ", "
    done;
    echo "],"

    QUERY_NUM=$((QUERY_NUM + 1))
done;
