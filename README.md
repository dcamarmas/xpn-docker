# Expand Docker (v3.0.0)


## Contents

 * [Some use cases with xpn-docker](https://github.com/xpn-arcos/xpn-docker/#some-use-cases-with-xpn-docker)
 * [Using xpn-docker](https://github.com/xpn-arcos/xpn-docker/#using-xpn-docker)


## Some use cases with xpn-docker

* Examples using Ad-Hoc XPN:

<html>
 <table>

  <tr>
  <td>
Expand (fuse)
  </td>
  <td>
Expand (bypass)
  </td>
  <td>
Expand (native)
  </td>
  </tr>

  <tr>
  <td>
<pre>
: 1. To start <b>3</b> containers
./xpn_docker.sh start <b>3</b>
./xpn_docker.sh status
<br>
: 2. Work from container <b>1</b>
./xpn_docker.sh bash <b>1</b>
<b>./test/xpn-mpi-fuse.sh</b>
exit
<br>
: 3. Stop all containers
./xpn_docker.sh stop
</pre>
  </td>
  <td>
<pre>
: 1. Spin up <b>3</b> containers
./xpn_docker.sh start <b>3</b>
./xpn_docker.sh status
<br>
: 2. Work from container <b>1</b>
./xpn_docker.sh bash <b>1</b>
<b>./test/xpn-mpi-bypass.sh</b>
exit
<br>
: 3. Stop all containers
./xpn_docker.sh stop
</pre>
  </td>
  <td>
<pre>
: 1. Spin up <b>3</b> containers
./xpn_docker.sh start <b>3</b>
./xpn_docker.sh status
<br>
: 2. Work from container <b>1</b>
./xpn_docker.sh bash <b>1</b>
<b>./test/xpn-mpi-native.sh</b>
exit
<br>
: 3. Stop all containers
./xpn_docker.sh stop
</pre>
  </td>
  </tr>

 </table>
</html>


* Examples of benchmarks with Ad-Hoc XPN:

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
<pre>
: 1. To start <b>3</b> containers,
: 2. sleep 5 seconds,
: 3. work from container <b>1</b>,
: 4. and stop all containers
<br>
./xpn_docker.sh \
    start <b>3</b> \
    sleep <b>5</b> \
    exec <b>1</b> "./benchmark/xpn-mpi-mdtest.sh" \
    stop
</pre>
  </td>
  <td>
<pre>
: 1. To start <b>3</b> containers,
: 2. sleep 5 seconds,
: 3. work from container <b>1</b>,
: 4. and stop all containers
<br>
./xpn_docker.sh \
    start <b>3</b> \
    sleep <b>5</b> \
    exec <b>1</b> "./benchmark/xpn-mpi-ior.sh" \
    stop
</pre>
  </td>
  </tr>
 </table>
</html>


* Examples of Ad-Hoc XPN with Apache Spark:

<html>
 <table>
  <tr>
  <td>
Apache Spark
<img width="650" height="1">
  </td>
  </tr>
  <tr>
  <td>
<pre>
: 1. To start <b>3</b> containers
./xpn_docker.sh start <b>3</b>
./xpn_docker.sh sleep 5
<br>
: 2. Work from container <b>1</b>
./xpn_docker.sh exec <b>1</b> <b>./spark/quixote-local.sh</b>
./xpn_docker.sh exec <b>1</b> <b>./spark/quixote-xpn.sh</b>
<br>
: 3. Stop all containers
./xpn_docker.sh stop
</pre>
  </td>
  </tr>
 </table>
</html>


## Using xpn-docker

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

**Please beware of**:
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


