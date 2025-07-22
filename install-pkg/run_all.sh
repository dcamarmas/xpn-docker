#!/bin/bash
set -x

# 1) Looping...
BASE_DIR=$(dirname $0)
FILES=$(ls -1 ${BASE_DIR}/*.sh | grep -v run_all.sh)

for F in $FILES; do
    echo "${F} ..."
    ${F}
done

