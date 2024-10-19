#!/bin/bash

# Did I overcomplicate this? It's too late to code...

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
EXPORT_DIR="${SCRIPT_DIR}/export"
FILE=$1

if [ ! -f "$FILE" ]; then
    >&2 echo "Not a file: ${FILE}"
    exit 1
fi
bn=$(basename $FILE)
newfile=${EXPORT_DIR}/${bn}

mkdir -p ${EXPORT_DIR}
cp -a ${FILE} $newfile

while read -r line; do
    needle=$(echo "$line" | sed -rn 's/^(.*)\xC2\xA0(.*)$/\1/p')
    file=$(echo "$line" | sed -rn 's/^(.*)\xC2\xA0(.*)$/\2/p')
    tempfile=$(mktemp)
    echo "// ### Begin inline ${needle} ###" > $tempfile
    cat $file >> $tempfile
    echo "// ### End inline ${needle} ###" >> $tempfile
    sed -i -n "/${needle}/!{p;d;}; r $tempfile" $newfile
    rm $tempfile
done < <(sed -rn 's/^(.*include <(\S+)>.*$)/\1\xC2\xA0\2/p' $newfile)

