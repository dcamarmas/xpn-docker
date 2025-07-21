#!/bin/bash
set -x

# 1) Base directory
BASE_DIR=$(dirname $0)

# 2) Looping...
FILES=$(ls -1 ${BASE_DIR}/essen*.sh)

for F in $FILES; do
    echo "${F} ..."
    ${F}
done

