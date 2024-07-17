#!/bin/bash

date +%Y%m%d%H%M%S

TRIES=3
QUERY_NUM=1

cat queries.sql | while read query; do
    echo -n "{\"query\": \""$query"\","
    echo -n "\"runtimes\": ["
    for i in $(seq 1 $TRIES); do
        RES=$(./query "$HOST" "$TOKEN" "$DATABASE" "$query" 2>&1 | tee >(cat) >> "${RESULTDIR}/${FILENAME}-query-output.log" ||:)
        FIRST_ITEM=$(echo "$RES" | head -n 1)
        [[ "$?" == "0" ]] && echo -n "${FIRST_ITEM}" || echo -n 0
        [[ "$i" != $TRIES ]] && echo -n ", "
    done;
        echo "]},"

    QUERY_NUM=$((QUERY_NUM + 1))
done;

date +%Y%m%d%H%M%S
