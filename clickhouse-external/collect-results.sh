#!/bin/bash

# export RESULTDIR=...
# export FILENAME=...

for f in $RESULTDIR/$FILENAME.log
do
    echo '
{
    "system": "ClickHouse",
    "date": "'$(date +%F)'",
    "start_time": "'$(head -n1 "$f" | tr -d "\n")'",
    "end_time": "'$(tail -n1 "$f" | tr -d "\n")'",

    "result": [
'$(grep -F "[" "$f" | head -c-2)'
]
}
' > $RESULTDIR/$FILENAME.json
done
    # "data_size": "'$(tail -n1 "$f" | tr -d "\n")'",
    # "load_time": "'$(head -n1 "$f" | tr -d "\n")'",
