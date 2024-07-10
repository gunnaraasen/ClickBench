#!/bin/bash

# export RESULTDIR=...

for f in "${RESULTDIR}"/clickhouse.log
do
    echo '
{
    "system": "ClickHouse Cloud",
    "date": "'$(date +%F)'",
    "load_time": '$(head -n1 "$f" | tr -d "\n")',
    "data_size": '$(tail -n1 "$f" | tr -d "\n")',

    "result": [
'$(grep -F "[" "$f" | head -c-2)'
]
}
' > "${RESULTDIR}"/clickhouse.json
done
