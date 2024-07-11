#!/bin/bash

# export RESULTDIR=...
# export JSONFILE=...

for f in "${RESULTDIR}"/timescaledb.log
do
    echo '
{
    "system": "TimescaleDB",
    "date": "'$(date +%F)'",
    "load_time": "'$(head -n1 "$f" | tr -d "\n")'",
    "data_size": "'$(tail -n1 "$f" | tr -d "\n")'",

    "result": [
'$(grep -F "[" "$f" | head -c-2)'
]
}
' > "${RESULTDIR}"/"${JSONFILE}"
done
