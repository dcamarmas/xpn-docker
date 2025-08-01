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


xpn_docker_welcome ()
{
        echo ""
        echo "  XPN-Docker v3.3"
        echo " -----------------"
        echo ""
}

xpn_docker_help_c ()
{
        echo "  Usage: $0 <action> [<options>]"
        echo ""
        echo "  :: First time + each time docker/dockerfile is updated, please execute:"
        echo "        * Single node:"
        echo "           $0 build"
        echo "        * Multi-node:"
        echo "           $0 build"
        echo "           $0 image-save"
        echo "           Change other compute nodes and load the image:"
        echo "           $0 image-load"
        echo ""
        echo "  :: Working with xpn-docker:"
        echo "     1) Starting the containers:"
        echo "        * Single node:"
        echo "           $0 start       <number of containers>"
        echo "        * Multi-node:"
        echo "           $0 swarm-create <machinefile_path>"
        echo "           $0 start        <number of containers>"
        echo ""
        echo "     2) To work with containers:"
        echo "        * To work within a single container:"
        echo "           $0 bash <container id, from 1 to number_of_containers>"
        echo "           <some work...>"
        echo "           exit"
        echo "        * To execute \"command\" on <number of containers> containers:"
        echo "           $0 mpirun <number of containers> \"<command>\""
        echo "        * To work on a single container:"
        echo "           $0 exec <container id, from 1 to number_of_containers> \"<command>\""
        echo ""
        echo "     3) Stopping the containers:"
        echo "        * Single node:"
        echo "           $0 stop"
        echo "        * Multi-node:"
        echo "           $0 stop"
        echo "           $0 swarm-destroy"
        echo ""
        echo "  :: Available option to uninstall xpn-docker (remove images + containers):"
        echo "        $0 cleanup"
        echo ""
}


#
# machine file create/remove
#

xpn_docker_machines_create ()
{
        # machines_mpi
        MODE=$1
        if [ "$MODE" == "SINGLE_NODE" ]; then
                CONTAINER_ID_LIST=$(docker ps -f name=node -q)
                docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID_LIST > machines_mpi
        fi
        if [ "$MODE" == "MULTI_NODE" ]; then
                CONTAINER_ID_LIST=$(docker service ps xpn_docker_node -f desired-state=running -q)
                docker inspect -f '{{range .NetworksAttachments}}{{.Addresses}}{{end}}' $CONTAINER_ID_LIST | sed "s/^\[//g" | awk 'BEGIN {FS="/"} ; {print $1}' > machines_mpi

        fi

        # machines_mpi -> machines_hosts + etc_hosts
        echo -n "" > machines_hosts
        echo -n "" > etc_hosts
        I=1
        while IFS= read -r line
        do
          echo       "node$I" >> machines_hosts
          echo "$line node$I" >> etc_hosts
          I=$((I+1))
        done < machines_mpi

        # machines_mpi -> machines_horovod
        cat machines_mpi | sed 's/.*/& slots=1/g' > machines_horovod

        # directories
        mkdir -p export/nfs

        # session mode
        echo $MODE > .xpn_docker_worksession
}

xpn_docker_machines_remove ()
{
        rm -fr machines_mpi
        rm -fr machines_hosts
        rm -fr etc_hosts
        rm -fr machines_horovod

        # directories
        rmdir -fail-on-non-empty export/nfs/* >& /dev/null

        # Remove session file...
        rm -fr .xpn_docker_worksession
}


#
# swarm create/destroy
#

xpn_docker_swarm_create ()
{
        # Check params
        if [ -f .xpn_docker_swarm ]; then
            echo ": The .xpn_docker_swarm file is found."
            echo ": * Please swarm-destroy first."
            echo ": * Please see './xpn_docker.sh help' for more information."
            echo ""
            exit
        fi

        # get machinefile name
        MACHINE_FILE=$1
        if [ "$MACHINE_FILE" == "" ]; then
            echo ": The machinefile name is empty."
            echo ": * Please see './xpn_docker.sh help' for more information."
            echo ""
            exit
        fi
        if [ ! -f $MACHINE_FILE ]; then
            echo ": The machinefile '$MACHINE_FILE' does not exist."
            echo ": * Please see './xpn_docker.sh help' for more information."
            echo ""
            exit
        fi

        NL=$(cat $MACHINE_FILE | grep -v ^$ | wc -l | cut -f1 -d" ")
        NWORKERS=$((NL-1))

        head -n 1         $MACHINE_FILE > /tmp/machinefile_1
        tail -n $NWORKERS $MACHINE_FILE > /tmp/machinefile_2
        HEAD_NODE=$(cat /tmp/machinefile_1)

        # swarm_join
        ssh $HEAD_NODE 'docker swarm init --advertise-addr $(hostname -i) | grep "docker swarm join --token"' > /tmp/docker_swarm_join.sh

        while IFS= read -r host
        do
           ssh ${host} 'bash -s' < /tmp/docker_swarm_join.sh
        done < /tmp/machinefile_2

        ssh $HEAD_NODE "docker node ls"

        # swarm mode
        echo "$HEAD_NODE" > .xpn_docker_swarm
}

xpn_docker_swarm_destroy ()
{
        # Check params
        if [ ! -f .xpn_docker_swarm ]; then
            echo ": The .xpn_docker_swarm file is not found."
            echo ": * Please swarm-create first."
            echo ": * Please see './xpn_docker.sh help' for more information."
            echo ""
            exit
        fi

        # get head node
        HEAD_NODE=$(cat .xpn_docker_swarm)

        # swarm_leave
        echo "docker swarm leave" > /tmp/docker_swarm_leave.sh

        while IFS= read -r host
        do
           ssh ${host} 'bash -s' < /tmp/docker_swarm_leave.sh
        done < /tmp/machinefile_2

        ssh $HEAD_NODE docker swarm leave --force

        # swarm mode
        rm -fr .xpn_docker_swarm
}


#
# build, start, ...
#

xpn_docker_build ()
{
        # Check params
        if [ ! -f docker/dockerfile ]; then
            echo ": The docker/dockerfile file is not found."
            echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git ?."
            echo ""
            exit
        fi

        # Build image
        HOST_UID=$1
        HOST_GID=$2
        CACHE=$3

        docker image build ${CACHE} -t expandfs/xpn-docker --build-arg UID=$HOST_UID --build-arg GID=$HOST_GID -f docker/dockerfile .
}

xpn_docker_save ()
{
   echo "Saving xpn-docker image..."
   docker image save xpn-docker | gzip -5 > xpn_docker.tgz 
}

xpn_docker_load ()
{
   # Check params
   if [ ! -f xpn_docker.tgz ]; then
      echo ": The xpn_docker.tgz file is not found."
      echo ": * Please see ./xpn_docker.sh help for more information."
      echo ""
      exit
   fi

   echo "Loading xpn-docker image..."
   cat xpn_docker.tgz | gunzip - | docker image load
}

xpn_docker_pull ()
{
   echo "Pulling xpn-docker image..."
   docker pull expandfs/xpn-docker
}

xpn_docker_start ()
{
        # get uid/gid
        HOST_UID_VALUE=$(id -u)
        HOST_GID_VALUE=$(id -g)
        N_ELTOS=$1

        # Check params
        if [ -f .xpn_docker_worksession ]; then
            echo ": There is an already running xpn_docker container."
            echo ": * Please stop first."
            echo ": * Please see './xpn_docker.sh help' for more information."
            echo ""
            exit
        fi

        # Check swarm active -> multi-node
        MODE=SINGLE_NODE
        if [ -f .xpn_docker_swarm ]; then
            MODE=MULTI_NODE
        fi

        # single/multi
        if [ "$MODE" == "SINGLE_NODE" ]; then

                # Start container cluster (single node)
                echo "Building containers..."
                HOST_UID=$HOST_UID_VALUE HOST_GID=$HOST_GID_VALUE docker compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME up -d --scale node=$N_ELTOS
                if [ $? -gt 0 ]; then
                    echo ": The docker compose command failed to spin up containers."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git ?."
                    echo ""
                    exit
                fi

                # Containers machine file
                xpn_docker_machines_create "SINGLE_NODE"

                # Update /etc/hosts on each node
                CONTAINER_ID_LIST=$(docker ps -f name=docker -q)
                for C in $CONTAINER_ID_LIST; do
                    docker container exec -it $C /work/lab-home/bin/hosts_update.sh
                done

        fi
        if [ "$MODE" == "MULTI_NODE" ]; then

                # Start container cluster (multi node)
                HOST_UID=$HOST_UID_VALUE HOST_GID=$HOST_GID_VALUE docker stack deploy --compose-file docker/dockerstack.yml $DOCKER_PREFIX_NAME
                if [ $? -gt 0 ]; then
                    echo ": The docker stack deploy command failed to spin up containers."
                    echo ""
                    exit
                fi

                docker service scale xpn_docker_node=$N_ELTOS
                if [ $? -gt 0 ]; then
                    echo ": The docker service scale command failed to spin up containers."
                    echo ""
                    exit
                fi

                # Containers machine file
                xpn_docker_machines_create "MULTI_NODE"
        fi
}

xpn_docker_stop ()
{
        # get uid/gid
        HOST_UID_VALUE=$(id -u)
        HOST_GID_VALUE=$(id -g)

        # get current session mode
        MODE=""
        if [ -f .xpn_docker_worksession ]; then
             MODE=$(cat .xpn_docker_worksession)
        fi

        # Check swarm active -> multi-node
        echo "Stopping containers..."
        if [ "$MODE" == "SINGLE_NODE" ]; then

             HOST_UID=$HOST_UID_VALUE HOST_GID=$HOST_GID_VALUE docker compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME down
             if [ $? -gt 0 ]; then
                 echo ": The 'docker compose' command failed to stop containers."
                 echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git ?."
                 echo ""
                 exit
             fi

        fi
        if [ "$MODE" == "MULTI_NODE" ]; then

             docker service rm xpn_docker_node
             if [ $? -gt 0 ]; then
                 echo ": The 'docker service' command failed to stop containers."
                 echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git ?."
                 echo ""
                 exit
             fi

        fi

        # Remove container cluster files...
        xpn_docker_machines_remove
}

xpn_docker_bash ()
{
        # Get parameters
        CO_ID=$1
        CO_NC=$2

        # Check params
        if [ $CO_ID -lt 1 ]; then
                echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                shift
                continue
        fi
        if [ $CO_ID -gt $CO_NC ]; then
                echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                shift
                continue
        fi

        # get current session mode
        MODE=""
        if [ -f .xpn_docker_worksession ]; then
             MODE=$(cat .xpn_docker_worksession)
        fi

        # get current session mode
        if [ "$MODE" == "SINGLE_NODE" ]; then

             # Bash on container...
             CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
             echo "Executing /bin/bash on container $CO_NAME with container id: $CO_ID ..."
             docker exec -it --user lab $CO_NAME /bin/bash -l

        fi
        if [ "$MODE" == "MULTI_NODE" ]; then

             # ssh to container...
             CO_IP=$(head -$1 machines_mpi | tail -1)
             CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -1)
             if [ "x$CO_NAME" == "x" ]; then
                  echo ": There is not a running xpn container on this node."
                  echo ": * Please swarm-create first."
                  echo ": * Please see ./xpn_docker.sh help for more information."
                  echo ""
                  exit
             fi

             echo "Executing /bin/bash on container $CO_NAME ..."
             docker container exec -it --user lab $CO_NAME /usr/bin/ssh $CO_IP

        fi
}


#
# Main
#

# Usage
if [ $# -eq 0 ]; then
        xpn_docker_welcome
        xpn_docker_help_c
        exit
fi


#
# check docker
#

docker -v >& /dev/null
status=$?
if [ $status -ne 0 ]; then
     echo ": docker is not found in this computer."
     echo ": * Did you install docker?."
     echo ":   Please visit https://docs.docker.com/get-docker/"
     echo ""
     exit
fi


#
# for each argument, try to execute it
#

DOCKER_PREFIX_NAME=xpn_docker
mkdir -p export

while (( "$#" ))
do
        arg_i=$1
        case $arg_i in
             clean-build)
                echo "Building initial clean image..."
                HOST_UID=$(id -u)
                HOST_GID=$(id -g)

                xpn_docker_build $HOST_UID $HOST_GID "--no-cache"
             ;;

             build)
                echo "Building initial image..."
                HOST_UID=$(id -u)
                HOST_GID=$(id -g)

                xpn_docker_build $HOST_UID $HOST_GID ""
             ;;

             image-save)
                echo "Saving image..."

                xpn_docker_save
             ;;

             image-load)
                echo "Loading image..."
                
                xpn_docker_load
             ;;

             image-pull)
                echo "Pulling image..."
                
                xpn_docker_pull
             ;;

             swarm-create)
                # Get parameters
                shift
                MF=$1

                xpn_docker_swarm_create $MF
             ;;

             swarm-destroy)
                xpn_docker_swarm_destroy
             ;;

             start)
                # Get parameters
                shift
                NN=$1

                xpn_docker_start $NN
             ;;

             stop)
                xpn_docker_stop
             ;;

             bash)
                # Get parameters
                shift
                CO_ID=$1
                CO_NC=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | wc -l)

                xpn_docker_bash ${CO_ID} ${CO_NC}
             ;;

             kill)
                # Stopping containers
                echo "Stopping containers..."

                HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME kill
                if [ $? -gt 0 ]; then
                    echo ": The docker compose command failed to stop containers."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git ?."
                    echo ""
                    exit
                fi

                # Remove container cluster (single node) files...
                xpn_docker_machines_remove
             ;;

             status)
                echo "Show status of current containers..."
                docker ps
             ;;

             network)
                echo "Show status of current IPs..."
                CONTAINER_ID_LIST=$(docker ps -f name=$DOCKER_PREFIX_NAME -q)
                docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID_LIST
             ;;

             cleanup)
                # Removing everything (warning) 
                echo "Removing containers and images..."
                docker rm      -f $(docker ps     -a -q)
                docker rmi     -f $(docker images -a -q)
                docker volume rm  $(docker volume ls -q)
                docker network rm $(docker network ls|tail -n+2|awk '{if($2 !~ /bridge|none|host/){ print $1 }}')
             ;;

             mpirun)
                # Get parameters
                shift
                NP=$1
                shift
                A=$@
                shift
                shift

                CNAME=$(docker ps -f name=node -q | head -1)

                # Check params
                if [ "x$CNAME" == "x" ]; then
                    echo ": There is not a running xpn-docker container."
                    exit
                fi

                if [ ! -f machines_mpi ]; then
                    echo ": The machines_mpi file was not found."
                    exit
                fi

                # XPN-Docker
                docker container exec -it $CNAME     \
                       mpirun -np $NP -machinefile machines_mpi \
                       $A
             ;;

             exec)
                # Get parameters
                shift
                CO_ID=$1
                shift
                A=$1
                CO_NC=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | wc -l)

                # Check params
                if [ $CO_ID -lt 1 ]; then
                   echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                   continue
                fi
                if [ $CO_ID -gt $CO_NC ]; then
                   echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                   continue
                fi

                # Bash on container...
                echo "Executing $A on container $CO_ID..."
                CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
                docker exec -it --user lab $CO_NAME bash -lc "source .profile; $A"
             ;;

             help)
                xpn_docker_welcome
                xpn_docker_help_c
             ;;

             sleep)
                # Get parameters
                shift
                NP=$1

                # Sleep...
                echo "Sleeping $NP seconds..."
                sleep ${NP}
             ;;

             *)
                echo ""
                echo "Unknow command: $1"
                $0 help
             ;;
        esac

        shift
done

