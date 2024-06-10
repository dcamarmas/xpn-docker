#!/bin/bash
set -x


sudo chown lab:lab /shared

export XPN_CONF=/shared/config.txt
export XPN_LOCALITY=1
SERVER_TYPE=mpi
# SERVER_TYPE=sck
# export XPN_SCK_PORT=5555
# export XPN_DEBUG=1
# export XPN_THREAD=1
# unset XPN_DEBUG

sleep 1

# 1) build configuration file /shared/config.txt
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)

/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp -n $NL -v start
sleep 2

# 3) start xpn client
mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/bin/ior/bin/mdtest -d /tmp/expand/xpn -I 5 -z 1 -b 2 -u -e 100k -w 200k

# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -d /work/machines_mpi stop
sleep 2

pkill mpiexec

