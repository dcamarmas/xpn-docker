#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be downloaded>"
	exit
fi

# 2) Clean-up
DESTINATION_PATH=$1

export MPICC_PATH=/home/lab/bin/mpich/bin/
export MPICC=$MPICC_PATH/mpicc
export CC=$MPICC_PATH/mpicc
export PATH=$MPICC_PATH:$PATH

# 3) Download MPICH
mkdir -p ${DESTINATION_PATH}
cd       ${DESTINATION_PATH}
wget https://github.com/hpc/ior/releases/download/4.0.0/ior-4.0.0.tar.gz
tar zxf ior-4.0.0.tar.gz
ln   -s ior-4.0.0         ior

# 5) Install IOR (from source code)
mkdir -p /home/lab/bin

cd ${DESTINATION_PATH}/ior
./bootstrap
./configure --prefix="/home/lab/bin/ior"

make clean
make -j 8
make install

mkdir -p "/home/lab/bin/ior/lib64"
ln    -s "/home/lab/bin/ior/lib64"   "/home/lab/bin/ior/lib"

