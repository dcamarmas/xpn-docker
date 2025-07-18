# Expand Docker -- version 3.2


## Contents

 * [1. Some xpn-docker use cases: multiple containers on single node](https://github.com/xpn-arcos/xpn-docker/#1-some-xpn-docker-use-cases-multiple-containers-on-single-node)
   * [1.1 Examples using XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#11-examples-using-xpn-ad-hoc)
   * [1.2 Examples of benchmarks with XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#12-examples-of-benchmarks-with-xpn-ad-hoc)
   * [1.3 Examples of Apache Spark and Ad-Hoc XPN](https://github.com/xpn-arcos/xpn-docker/#13-examples-of-ad-hoc-xpn-with-apache-spark)
 * [2. Some xpn-docker use cases: multiple containers on multiple nodes](https://github.com/xpn-arcos/xpn-docker/#2-some-xpn-docker-use-cases-multiple-containers-on-multiple-nodes)
   * [2.1 To build and to distribute the container image in multiple nodes](https://github.com/xpn-arcos/xpn-docker/#21-to-build-and-to-distribute-the-container-image-in-multiple-nodes)
   * [2.2 Examples using XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#22-examples-using-xpn-ad-hoc)
 * [3. Summary of using xpn-docker](https://github.com/xpn-arcos/xpn-docker/#2-summary-of-using-xpn-docker)


## 1. Some xpn-docker use cases: multiple containers on single node

### 1.1 Example of using Expand with native API, with FUSE, and with LD_PRELOAD (bypass)

   <html>
   <table>
   <tr>
   <td>
   Expand (FUSE)
   </td>
   <td>
   Expand (LD_PRELOAD)
   </td>
   <td>
   Expand (native)
   </td>
   </tr>
   <tr>
   <td>
   </html>
     
   ```bash
 : Step 1. 
 ./xpn_docker.sh start 3
 ./xpn_docker.sh status

 : Step 2. 
 ./xpn_docker.sh bash 1
 ./test/xpn-mpi-fuse.sh
 exit

 : Step 3. 
 ./xpn_docker.sh stop
   ```

  <html>
  </td>
  <td>
  </html>

  ```bash
 : Step 1. 
 ./xpn_docker.sh start 3
 ./xpn_docker.sh status

 : Step 2. 
 ./xpn_docker.sh bash 1
 ./test/xpn-mpi-bypass.sh
 exit

 : Step 3. 
 ./xpn_docker.sh stop
  ```

  <html>
  </td>
  <td>
  </html>

  ```bash
 : Step 1. 
 ./xpn_docker.sh start 3
 ./xpn_docker.sh status

 : Step 2. 
 ./xpn_docker.sh bash 1
 ./test/xpn-mpi-native.sh
 exit

 : Step 3. 
 ./xpn_docker.sh stop
  ```

  <html>
  </td>
  </tr>
  </table>
  </html>


  The steps are:
  1. First, starting 3 containers
  2. Then, do some work from container 1
     * Bash on container 1
     * Execute example with Expand native access or access by using FUSE or by using LD_PRELOAD
     * Exit from container 1
  4. Finally, stop all containers


### 1.2 Examples of benchmarks with XPN Ad-Hoc

  <html>
  <table>
  <tr>
  <td>
MDtest
<img width="325" height="1">
  </td>
  <td>
IOR
<img width="325" height="1">
  </td>
  </tr>
  <tr>
  <td>
  </html>
   
  ```bash
  : 1. To start 3 containers,
  : 2. sleep 5 seconds,
  : 3. work from container 1,
  : 4. and stop all containers
  
  ./xpn_docker.sh \
     start 3 \
     sleep 5 \
     exec 1 "./benchmark/xpn-mpi-mdtest.sh" \
     stop
  ```

  <html>
  </td>
  <td>
  </html>
   
  ```bash
  : 1. To start 3 containers,
  : 2. sleep 5 seconds,
  : 3. work from container 1,
  : 4. and stop all containers
  
  ./xpn_docker.sh \
     start 3 \
     sleep 5 \
     exec 1 "./benchmark/xpn-mpi-ior.sh" \
     stop
  ```
    
  <html>
  </td>
  </tr>
  </table>
  </html>


### 1.3 Examples of Ad-Hoc XPN with Apache Spark

<html>
 <table>
  <tr>
  <td>
  Word count <img width="650" height="1">
  </td>
  </tr>
  <tr>
  <td>
  </html>
  
  ```bash
  : 1. To start 3 containers
  ./xpn_docker.sh start 3
  ./xpn_docker.sh sleep 5

  : 2. Work from container 1
  ./xpn_docker.sh exec 1 ./spark/quixote-local.sh
  ./xpn_docker.sh exec 1 ./spark/quixote-xpn.sh

  : 3. Stop all containers
  ./xpn_docker.sh stop
  ```
  
  <html>
  </td>
  </tr>
 </table>
</html>


## 2. xpn-docker use case: multiple containers on multiple nodes

### 2.1 To build and to distribute the container image in multiple nodes

   The first time or when docker/dockerfile is updated:
   1. On one node: build image node and save the image:
       ```bash
       ./xpn-docker.sh clean-build
       ./xpn-docker.sh image-save
       ```
   2. On the other nodes: copy the image and load the image (node-x in this example):
       ```bash
       scp xpn_docker.tgz  node-x
       ssh node-x ./xpn-docker.sh image-load
       ```


### 2.2 Example of using Expand with native API 

   General steps are:
   ```bash
    : Step 1: Starting docker swarm
    ./xpn-docker.sh swarm-create machinefile

    : Step 2: Starting containers
    NC=$(wc machines | awk '{print $1}')
    ./xpn-docker.sh start $NC

    : Step 3: Doing execution
    ./benchmark/xpn-mpi-native.sh
    
    : Step 4: Stopping containers (undoing 2)
    ./xpn-docker.sh stop

    : Step 5: Stopping docker swarm (undoing 1)
    ./xpn-docker.sh swarm-destroy
   ```


## 3. Summary of using xpn-docker

* Summary:
  <html>
  <table>
  <tr>
  <th colspan="2">Action</th>
  <th>Command</th>
  </tr>

  <tr>
  <td colspan="2"> First time + "each time ./docker/dockerfile is updated"  </td>
  <td><code>./xpn_docker.sh build</code>
  </td>
  </tr>

  <tr>
  <td rowspan="4">
  Work session
  </td>
  <td colspan="1"> To spin up <b>3</b> containers </td>
  <td><code>./xpn_docker.sh start <b>3</b></code>
  </td>
  </tr>

  <tr>
  <td colspan="1"> To get into container <b>1</b>  </td>
  <td><code> ./xpn_docker.sh bash <b>1</b></code>
  </td>
  </tr>

  <tr>
  <td colspan="1"> To exit from container </td>
  <td><code>exit</code>  </td>
  </tr>

  <tr>
  <td colspan="1"> To spin down all containers </td>
  <td><code>./xpn_docker.sh stop</code>
  </td>
  </tr>

  <tr>
  <td rowspan="2">
  Options for debugging
  </td>
  <td>  
  To check running containers
  </td>
  <td>
  <code>./xpn_docker.sh status</code>
  </td>
  </tr>

  <tr>
  <td>  
  To get the containers internal IP addresses
  </td>
  <td>
  <code>./xpn_docker.sh network</code>
  </td>
  </tr>
 
  </table>
  </html>

* **Please beware of**:
   * Any modification outside the "/work" directory will be discarded on container stopping.
   * Please make a backup of your work "frequently" (just in case).
   * You might need to use "sudo" before ./xpn_docker.sh if your user doesn't belong to the docker group
     * It could be solved by using "sudo usermod -aG docker ${USER}"


## Authors
* :technologist: Félix García-Carballeira
* :technologist: Alejandro Calderón Mateos
* :technologist: Diego Camarmas Alonso
* :technologist: Dario Muñoz Muñoz
* :technologist: Elias del Pozo Puñal


