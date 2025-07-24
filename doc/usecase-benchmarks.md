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


### Examples of benchmarks with XPN Ad-Hoc

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


