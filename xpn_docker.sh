#!/bin/bash
#set -x

#
#  Copyright 2019-2024 Alejandro Calderon Mateos, Felix Garcia Carballeira, Diego Camarmas Alonso, Jose Rivadeneira Lopez-Bravo, Dario Muñoz Muñoz
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
        echo "  XPN-Docker (v3.0.0)"
        echo " ---------------------"
        echo ""
}

xpn_docker_help_c ()
{
        echo "  Usage: $0 <action> [<options>]"
        echo ""
        echo "  :: First time + each time docker/dockerfile is updated, please execute:"
        echo "        $0 build"
        echo ""
        echo "  :: Working with xpn-docker:"
        echo "     1) Starting the containers:"
        echo "        $0 start <number of containers>"
        echo ""
        echo "     2.a) To work within a single container:"
        echo "            $0 bash <container id, from 1 to number_of_containers>"
        echo "            <some work...>"
        echo "            exit"
        echo "     2.b) To execute \"command\" on <number of containers> containers:"
        echo "            $0 mpirun <number of containers> \"<command>\""
        echo "     2.c) To work on a single container:"
        echo "            $0 exec <container id, from 1 to number_of_containers> \"<command>\""
        echo ""
        echo "     3) Stopping the containers:"
        echo "        $0 stop"
        echo ""
        echo "  :: Available option to uninstall xpn-docker (remove images + containers):"
        echo "        $0 cleanup"
        echo ""
}


xpn_docker_machines_create ()
{
        # Container cluster (single node) machine list
        CONTAINER_ID_LIST=$(docker ps -f name=node -q)
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID_LIST > machines_mpi

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

        mkdir -p export/nfs
}

xpn_docker_machines_remove ()
{
        rm -fr machines_mpi
        rm -fr machines_hosts
        rm -fr etc_hosts

        rmdir -fail-on-non-empty export/nfs/* >& /dev/null
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

DOCKER_PREFIX_NAME=docker
mkdir -p export

while (( "$#" ))
do
        arg_i=$1
        case $arg_i in
             build)
                # Check params
                if [ ! -f docker/dockerfile ]; then
                    echo ": The docker/dockerfile file is not found."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git?."
                    echo ""
                    exit
                fi

                # Build image
                echo "Building initial image..."
                HOST_UID=$(id -u)
                HOST_GID=1000
                docker image build --no-cache -t xpn-docker --build-arg UID=$HOST_UID --build-arg GID=$HOST_GID -f docker/dockerfile .
             ;;

             start)
                # Get parameters
                shift
                NP=$1

                # Start container cluster (single node)
                echo "Building containers..."
                HOST_UID=$(id -u) HOST_GID=1000 docker-compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME up -d --scale node=$NP
                if [ $? -gt 0 ]; then
                    echo ": The docker-compose command failed to spin up containers."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git?."
                    echo ""
                    exit
                fi

                # Containers machine file
                xpn_docker_machines_create

                # Update /etc/hosts on each node
                CONTAINER_ID_LIST=$(docker ps -f name=docker -q)
                for C in $CONTAINER_ID_LIST; do
                    docker container exec -it $C /work/lab-home/bin/hosts_update.sh
                done
             ;;

             bash)
                # Get parameters
                shift
                CO_ID=$1
                CO_NC=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | wc -l)

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

                # Bash on container...
                echo "Executing /bin/bash on container $CO_ID..."
                CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
                # echo "Coname $CO_NAME"
                docker exec -it --user lab $CO_NAME /bin/bash -l
             ;;

             stop)
                # Stopping containers
                echo "Stopping containers..."
                HOST_UID=$(id -u) HOST_GID=1000 docker-compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME down
                if [ $? -gt 0 ]; then
                    echo ": The docker-compose command failed to stop containers."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git?."
                    echo ""
                    exit
                fi

                # Remove container cluster (single node) files...
                xpn_docker_machines_remove
             ;;

             kill)
                # Stopping containers
                echo "Stopping containers..."
                HOST_UID=$(id -u) HOST_GID=1000 docker-compose -f docker/dockercompose.yml -p $DOCKER_PREFIX_NAME kill
                if [ $? -gt 0 ]; then
                    echo ": The docker-compose command failed to stop containers."
                    echo ": * Did you execute git clone https://github.com/xpn-arcos/xpn-docker.git?."
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

