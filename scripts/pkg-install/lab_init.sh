#!/bin/bash
set -x

# (4) OpenSSH: keygen
mkdir -p  /home/lab/.ssh
chmod 700 /home/lab/.ssh
ssh-keygen -q -t rsa -N "" -f /home/lab/.ssh/id_rsa
ssh-keygen -q -t dsa -N "" -f /home/lab/.ssh/id_dsa
cat /home/lab/.ssh/id_dsa.pub >> /home/lab/.ssh/authorized_keys
cat /home/lab/.ssh/id_rsa.pub >> /home/lab/.ssh/authorized_keys
chmod 700 /home/lab/.ssh

