# Expand Docker v3.2


## Contents

 * [Summary of using xpn-docker](https://github.com/xpn-arcos/xpn-docker/#using-xpn-docker)
 * [Examples of benchmarks with XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#examples-of-benchmarks-with-xpn-ad-hoc)
 * [Examples using XPN Ad-Hoc](https://github.com/xpn-arcos/xpn-docker/#examples-using-xpn-ad-hoc)
 * [Examples of Ad-Hoc XPN with Apache Spark](https://github.com/xpn-arcos/xpn-docker/#examples-of-ad-hoc-xpn-with-apache-spark)


## Using xpn-docker

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


## Examples of benchmarks with XPN Ad-Hoc

   * IOR <img width="325" height="1">

      ```bash
      : 1. To start 3 containers,
      : 2. sleep 5 seconds,
      : 3. work from container 1,
      : 4. and stop all containers
      
      ./xpn_docker.sh \
          start 3 \
          sleep 5 \
          exec  1 "./benchmark/xpn-mpi-ior.sh" \
          stop
      ```
      
   * MDtest <img width="325" height="1">

      ```bash
      : 1. To start 3 containers,
      : 2. sleep 5 seconds,
      : 3. work from container 1,
      : 4. and stop all containers
      
      ./xpn_docker.sh \
          start 3 \
          sleep 5 \
          exec  1 "./benchmark/xpn-mpi-mdtest.sh" \
          stop
      ```




## Examples using XPN Ad-Hoc

  * Expand (fuse)

      ```bash
      : 1. To start 3 containers
      ./xpn_docker.sh start 3
      ./xpn_docker.sh status

      : 2. Work from container 1
      ./xpn_docker.sh bash 1
      ./test/xpn-mpi-fuse.sh
      exit

      : 3. Stop all containers
      ./xpn_docker.sh stop
      ```

  * Expand (bypass)

      ```bash
      : 1. To start 3 containers
      ./xpn_docker.sh start 3
      ./xpn_docker.sh status

      : 2. Work from container 1
      ./xpn_docker.sh bash 1
      ./test/xpn-mpi-bypass.sh
      exit

      : 3. Stop all containers
      ./xpn_docker.sh stop
      ```

  * Expand (native)

      ```bash
      : 1. To start 3 containers
      ./xpn_docker.sh start 3
      ./xpn_docker.sh status

      : 2. Work from container 1
      ./xpn_docker.sh bash 1
      ./test/xpn-mpi-native.sh
      exit

      : 3. Stop all containers
      ./xpn_docker.sh stop
      ```



##  Examples of Ad-Hoc XPN with Apache Spark
      
   * Word count with Apache Spark <img width="650" height="1">

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
      


## Authors
* :technologist: Félix García-Carballeira
* :technologist: Alejandro Calderón Mateos
* :technologist: Diego Camarmas Alonso
* :technologist: Dario Muñoz Muñoz
* :technologist: Elias del Pozo Puñal


