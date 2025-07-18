#!/bin/bash
#set -x

#
#  Copyright 2019-2025 Alejandro Calderon Mateos, Felix Garcia Carballeira, Diego Camarmas Alonso, Jose Rivadeneira Lopez-Bravo, Dario Muñoz Muñoz
#
#  This file is part of XPN-Docker proyect.
#
#  XPN-Docker is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  XPN-Docker is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with XPN-Docker.  If not, see <http://www.gnu.org/licenses/>.
#


# Start RPCbind
/usr/sbin/service rpcbind start
status=$?
if [ $status -ne 0 ]; then
     echo "Failed to start rpcbind: $status"
fi

# Start NFS-server
mkdir -p /export/nfs/$(hostname -i)
echo "/export/nfs/$(hostname -i) $(hostname -i)/28(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports

/usr/sbin/service nfs-kernel-server start
status=$?
if [ $status -ne 0 ]; then
     echo "Failed to start nfs-kernel-server: $status"
fi

# Start SSHD
/usr/sbin/sshd -D
status=$?
if [ $status -ne 0 ]; then
     echo "Failed to start sshd: $status"
     exit $status
fi
