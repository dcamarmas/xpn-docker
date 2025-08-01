# xpn-docker: Expand Docker

<details>

<summary><h2>Contents</h2></summary>

 1. [Summary of using xpn-docker](/docs/summary.md)
 2. [Build the container image](/docs/image.md)
 3. Some xpn-docker use cases:
    1. [Examples using XPN Ad-Hoc](/docs/usecase-xpn.md)
    2. [Examples of benchmarks with XPN Ad-Hoc](/docs/usecase-benchmarks.md)
    3. [Example  of Apache Spark and Ad-Hoc XPN](/docs/usecase-spark.md)
 4. [Multiple containers on multiple nodes](/docs/swarm.md)
 5. [Authors](/docs/authors.md)

</details>


  ```mermaid
flowchart LR
    A([Start]) --> B("First time OR dockerfile updated?")
    B -- Yes --> CImage_local
    B -- No  --> D

    subgraph CImage_local [1 Build image]
        A2[./xpn_docker.sh build] 
    end

    CImage_local --> C("multinode image?")
    C -- Yes --> CImage_swarm
    C -- No  --> D

    subgraph CImage_swarm [2 Deploy image]
        direction TB
        A4[./xpn_docker.sh image-save] --> A5[./xpn_docker.sh image-load]
    end

    CImage_swarm --> D("multinode execution?")
    D -- Yes --> MNodes
    D -- No  --> WSession

    subgraph MNodes [3 Start swarm]
        direction TB
        A6[./xpn-docker.sh swarm-create machinefile]
    end

    MNodes --> WSession

    subgraph WSession [4 Work Session]
        direction TB
        C1[./xpn_docker.sh start 3] --> C2
        C2[./xpn_docker.sh bash 1]  --> C3
        C3[exit] --> C4[./xpn_docker.sh stop]
    end

    WSession --> E("multinode execution?")
    E -- Yes --> MNodes_stop
    E -- No  --> Z

    subgraph MNodes_stop [5 Stop swarm]
        A7[./xpn-docker.sh swarm-destroy]
    end

    MNodes_stop --> Z([Stop])
  ```


## Summary of using xpn-docker

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
  <td colspan="1"> build image <br> IF((First time OR dockerfile updated)) </td>
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
  <td rowspan="3">
  Multiple nodes
  </td>
  <td>  
  Starting docker swarm
  </td>
  <td>
  <code>./xpn-docker.sh swarm-create machinefile</code>
  </td>
  </tr>
  <tr>
  <td colspan="2">
  [[ Work session ]]
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
  Get information
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

