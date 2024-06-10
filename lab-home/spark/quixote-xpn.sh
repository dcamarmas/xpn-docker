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
# (1) Start mpi_servers in background
#

sudo chown lab:lab /shared
NL=$(cat /work/machines_mpi | wc -l)
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL start


#
# (2) Get data
#

# get local data
if [ ! -f /home/lab/spark/2000-0.txt ]; then
     curl https://www.gutenberg.org/files/2000/2000-0.txt -o /home/lab/spark/2000-0.txt
fi

# replication
/home/lab/bin/replicate.sh /home/lab/src/spark/conf/workers /home/lab/spark/2000-0.txt

# copy data into XPN
export XPN_CONF=/shared/config.txt
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/libmxml.so:$LD_LIBRARY_PATH
#
# LD_PRELOAD=/home/lab/bin/xpn/lib/xpn_bypass.so:$LD_PRELOAD  cp  /home/lab/spark/2000-0.txt  /tmp/expand/xpn/2000-0.txt
# /home/lab/src/xpn/src/utils/cp-local2xpn /home/lab/spark/2000-0.txt /xpn/2000-0.txt


#
# (3) Run work
#

# clean
rm -fr /home/lab/spark/2000-wc

# spark cluster
/home/lab/src/spark/sbin/start-all.sh
sleep 2
LD_PRELOAD=/home/lab/bin/xpn/lib/xpn_bypass.so:$LD_PRELOAD  spark-submit /home/lab/spark/quixote.py  --master "spark://node1:7077" --minput "/tmp/expand/xpn/2000-0.txt" --moutput "/tmp/expand/xpn/2000-wc"
sleep 2
/home/lab/src/spark/sbin/stop-all.sh

# show results
LD_PRELOAD=/home/lab/bin/xpn/lib/xpn_bypass.so:$LD_PRELOAD  ls -als /tmp/expand/xpn/2000-wc


#
# (4) stop mpi_servers
#
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop

