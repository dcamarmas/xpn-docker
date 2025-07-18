# Expand Docker -- version 3.2


## Contents

 * [1. Summary of using xpn-docker](https://github.com/xpn-arcos/xpn-docker/#1-summary-of-using-xpn-docker)
 * [2. Build the container image](https://github.com/xpn-arcos/xpn-docker/#2-build-the-container-image)
 * [3. Some xpn-docker use cases](https://github.com/xpn-arcos/xpn-docker/#3-some-xpn-docker-use-cases)
   * [3.1 Examples using XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#31-examples-using-xpn-ad-hoc)
   * [3.2 Examples of benchmarks with XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#32-examples-of-benchmarks-with-xpn-ad-hoc)
   * [3.3 Examples of Apache Spark and Ad-Hoc XPN](https://github.com/xpn-arcos/xpn-docker/#33-examples-of-ad-hoc-xpn-with-apache-spark)
 * [4. Multiple containers on multiple nodes](https://github.com/xpn-arcos/xpn-docker/#4-multiple-containers-on-multiple-nodes)


## 1. Summary of using xpn-docker

* Summary:
  <html>
  <table>
  <tr>
  <th colspan="2">Action</th>
  <th>Command</th>
  </tr>

  <tr>
  <td rowspan="3">
  Container image
  </td>
  <td colspan="1"> First time + when dockerfile is updated </td>
  <td><code>./xpn_docker.sh build</code>
  </td>
  </tr>
  <tr>
  <td colspan="1"> Save image  </td>
  <td><code> ./xpn_docker.sh image-save</code>
  </td>
  </tr>
  <tr>
  <td colspan="1"> Load image  </td>
  <td><code> ./xpn_docker.sh image-load</code>
  </td>
  </tr>

  <tr>
  <td rowspan="2">
  Options for multiple nodes
  </td>
  <td>  
  Starting docker swarm
  </td>
  <td>
  <code>./xpn-docker.sh swarm-create machinefile</code>
  </td>
  </tr>
  <tr>
  <td>  
  Stopping docker swarm
  </td>
  <td>
  <code>./xpn-docker.sh swarm-destroy</code>
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



## 2. Build the container image

The first time xpn-docker is deployed or when the ```docker/dockerfile``` is updated we need to build the container image.

  * To build the container image for a single node:
       ```bash
       ./xpn-docker.sh clean-build
       ```

  * To build and distribute the container image to multiple nodes:
    * Build and save the image to the ```xpn_docker.tgz``` file by using:
        ```bash
       ./xpn-docker.sh clean-build
        ./xpn-docker.sh image-save
        ```
    2. Copy ```xpn_docker.tgz``` to other nodes, and load this file:
        ```bash
        scp xpn_docker.tgz  node-x
        ssh node-x ./xpn-docker.sh image-load
        ```



## 3. Some xpn-docker use cases

### 3.1 Example of using Expand with native API, with LD_PRELOAD (bypass), and with FUSE

   <br>
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
 cd ./test
 ./xpn-mpi-fuse.sh
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
 cd ./test
 ./xpn-mpi-bypass.sh
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
 cd ./test
 ./xpn-mpi-native.sh
 exit

 : Step 3. 
 ./xpn_docker.sh stop
  ```

  <html>
  </td>
  </tr>
  </table>
  </html>


  Then, the general steps are:
   1. Starting 3 containers
   2. Then, do some work from container 1
      * Bash on container 1
      * Execute example with Expand native access or access by using FUSE or by using LD_PRELOAD
      * Exit from container 1
   4. Stopping all containers


### 3.2 Examples of benchmarks with XPN Ad-Hoc

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


### 3.3 Examples of Ad-Hoc XPN with Apache Spark

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


## 4. Multiple containers on multiple nodes

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



## Authors
* :technologist: Félix García-Carballeira
* :technologist: Alejandro Calderón Mateos
* :technologist: Diego Camarmas Alonso
* :technologist: Dario Muñoz Muñoz
* :technologist: Elias del Pozo Puñal


