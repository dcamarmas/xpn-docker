#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be downloaded>"
	exit
fi

# 2) Get arguments
DESTINATION_PATH=$1

# 3) Looping...
BASE_DIR=$(dirname $0)
FILES=$(ls -1 ${BASE_DIR}/*.sh | grep -v run_all.sh)

for F in $FILES; do
    echo "${F} ${DESTINATION_PATH} ..."
    ${F} ${DESTINATION_PATH}
done

