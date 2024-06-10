#!/bin/bash
set -x

sudo chown lab:lab /shared

export XPN_DEBUG=1
export XPN_THREAD=0
export XPN_LOCALITY=1


# 1) build configuration file /shared/config.txt
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL -p 2 start
sleep 2

# 3) start xpn client
mpiexec -np 1 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        /home/lab/src/xpn/test/performance/xpn-fault-tolerant/rnd-write-read-cmp /xpn/test 1 1
sleep 2

exit_code=$?
echo $?

# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop
echo "Exit code $exit_code"

netstat -tlnp

