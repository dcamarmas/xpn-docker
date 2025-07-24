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


### Examples of Ad-Hoc XPN with Apache Spark

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
      

