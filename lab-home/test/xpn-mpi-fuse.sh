#!/bin/bash
set -x


sudo chown lab:lab /shared

NL=$(cat /work/machines_mpi | wc -l)
UID=$(id -u)
GID=1000

# 1) build configuration file /shared/config.txt
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL start
sleep 2

# 3) start FUSE
mpiexec -np $NL \
	-hostfile /work/machines_mpi \
        /home/lab/src/xpn/src/connector_fuse/fuse-expand /tmp/fuse -d -s -o xpnpart=/xpn -o big_writes -o no_remote_lock -o intr -o uid=$UID -o gid=$GID &
sleep 2

# 4) start xpn client
mpiexec -np 1 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        /home/lab/src/xpn/test/integrity/bypass_c/open-write-close /tmp/fuse/test_1 10

# 5) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop

