#!/bin/bash
set -x


sudo chown lab:lab /shared

REPLICATION_LEVEL=2
export XPN_CONF=/shared/config.xml
export XPN_LOCALITY=1
# export XPN_SCK_PORT=5555
# export XPN_DEBUG=1


# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)

ls -rlash /home/lab/replication

/home/lab/src/xpn/scripts/execute/xpn.sh -s /home/lab/replication -x /tmp/ -l /work/machines_mpi -n $NL -p $REPLICATION_LEVEL preload

rm   -rf /shared/flush
mkdir -p /shared/flush

# mpiexec -l -np $NL \
#         -hostfile        /work/machines_mpi \
#         /home/lab/src/xpn/src/utils/xpn_flush /tmp /shared/flush 524288 $REPLICATION_LEVEL
/home/lab/src/xpn/scripts/execute/xpn.sh -x /tmp/ -t /shared/flush  -l /work/machines_mpi -n $NL -p $REPLICATION_LEVEL flush
/home/lab/src/xpn/scripts/execute/xpn.sh -x /tmp/ -e mpi -w /shared -l /work/machines_mpi -n $NL -p $REPLICATION_LEVEL -v start

ls -rlash /tmp
netstat -tlnp

diff <(cat /home/lab/replication/quijote-small.txt) <(mpiexec -np 1 -hostfile /work/machines_mpi /home/lab/src/xpn/src/utils/xpn-cat /xpn/quijote-small.txt)
diff <(cat /home/lab/replication/quijote.txt) <(mpiexec -np 1 -hostfile /work/machines_mpi /home/lab/src/xpn/src/utils/xpn-cat /xpn/quijote.txt)

mpiexec -np 1 -hostfile /work/machines_mpi /home/lab/src/xpn/src/utils/xpn-cat /xpn/quijote-small.txt
ls -rlash /home/lab/replication
ls -rlash /tmp
ls -rlash /shared/flush

diff <(cat /home/lab/replication/quijote-small.txt) <(cat /shared/flush/quijote-small.txt)
diff <(cat /home/lab/replication/quijote.txt) <(cat /shared/flush/quijote.txt)

# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -e mpi -w /shared -d /work/machines_mpi stop
pkill mpiexec

