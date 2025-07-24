# Expand Docker


## Contents

 * [1. Summary of using xpn-docker](https://github.com/xpn-arcos/xpn-docker/doc/summary.md)
 * [2. Build the container image](https://github.com/xpn-arcos/xpn-docker/doc/image.md)
 * 3. Some xpn-docker use cases:
   * [3.1 Examples using XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/doc/usecase-xpn.md)
   * [3.2 Examples of benchmarks with XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/usecase-benchmarks.md)
   * [3.3 Examples of Apache Spark and Ad-Hoc XPN](https://github.com/xpn-arcos/xpn-docker/usecase-spark.md)
 * [4. Multiple containers on multiple nodes](https://github.com/xpn-arcos/xpn-docker/swarm.md)
 * [Authors](https://github.com/xpn-arcos/xpn-docker/authors.md)


## Multiple containers on multiple nodes

   The general steps are:
   ```bash
   : Step 1: Starting docker swarm
   ./xpn-docker.sh swarm-create machinefile

        : Step 2: Starting containers
        NC=$(wc machines | awk '{print $1}')
        ./xpn-docker.sh start $NC

             : Step 3: Doing execution
             ./xpn_docker.sh bash 1
             ./benchmark/xpn-mpi-native.sh
             exit
    
        : Step 4: Stopping containers (undoing 2)
        ./xpn-docker.sh stop

   : Step 5: Stopping docker swarm (undoing 1)
   ./xpn-docker.sh swarm-destroy
   ```


