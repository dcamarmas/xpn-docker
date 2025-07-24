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


### Example of using Expand with native API, with LD_PRELOAD (bypass), and with FUSE

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


