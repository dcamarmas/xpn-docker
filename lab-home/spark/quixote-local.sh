#!/bin/bash
set -x


#
# (0) Set initial configuration
#

# source .profile first
if [[ -z "${PROFILE_LOADED}" ]]; then
  . /home/lab/.profile
fi

# configure workers (skip first for master)
tail -n +2 /work/machines_mpi > /home/lab/src/spark/conf/workers


#
# (1) Get data
#

# get local data
if [ ! -f /home/lab/spark/2000-0.txt ]; then
     curl https://www.gutenberg.org/files/2000/2000-0.txt -o /home/lab/spark/2000-0.txt
fi

# replication
/home/lab/bin/replicate.sh /home/lab/src/spark/conf/workers /home/lab/spark/2000-0.txt


#
# (2) Run work
#

# clean
rm -fr /home/lab/spark/2000-wc

# spark cluster
/home/lab/src/spark/sbin/start-all.sh
sleep 2
spark-submit /home/lab/spark/quixote.py --master "spark://node1:7077" --minput "/home/lab/spark/2000-0.txt" --moutput "/home/lab/spark/2000-wc"
sleep 2
/home/lab/src/spark/sbin/stop-all.sh

# show results
ls -als /home/lab/spark/2000-wc

