#!/bin/bash

date +%Y%m%d%H%M%S

TRIES=3
QUERY_NUM=1

cat queries.sql | while read query; do
    echo -n "{\"query\": \""$query"\","
    echo -n "\"runtimes\": ["
    for i in $(seq 1 $TRIES); do
        RES=$(./query "$HOST" "$TOKEN" "$DATABASE" "$query" 2>> "${RESULTDIR}/${FILENAME}-error.log" ||: )
        ELAPSED=$(echo $RES | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' || echo 0)
        [[ "$?" == "0" ]] && echo -n "${ELAPSED}" || echo -n 0
        [[ "$i" != $TRIES ]] && echo -n ", "
    done;
        echo "]},"

    QUERY_NUM=$((QUERY_NUM + 1))
done;

date +%Y%m%d%H%M%S
