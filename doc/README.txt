
Expand Docker (v3.1)
====================

Contents
--------

 :: Some use cases with xpn-docker
 :: Using xpn-docker


Some use cases with xpn-docker
------------------------------

   * Examples using XPN Ad-Hoc:

      ----------------------------------------------------------------------------------------------
     |   Expand (fuse)               |    Expand (bypass)            |    Expand (native)           |
      ----------------------------------------------------------------------------------------------
     |                               |                               |                              |
     | : 1. To start 3 containers    | : 1. Spin up 3 containers     | : 1. Spin up 3 containers    |
     | ./xpn_docker.sh start 3       | ./xpn_docker.sh start 3       | ./xpn_docker.sh start 3      |
     | ./xpn_docker.sh status        | ./xpn_docker.sh status        | ./xpn_docker.sh status       |
     |                               |                               |                              |
     | : 2. Work from container 1    | : 2. Work from container 1    | : 2. Work from container 1   |
     | ./xpn_docker.sh bash 1        | ./xpn_docker.sh bash 1        | ./xpn_docker.sh bash 1       |
     | ./test/xpn-mpi-fuse.sh        | ./test/xpn-mpi-bypass.sh      | ./test/xpn-mpi-native.sh     |
     | exit                          | exit                          | exit                         |
     |                               |                               |                              |
     | : 3. Stop all containers      | : 3. Stop all containers      | : 3. Stop all containers     |
     | ./xpn_docker.sh stop          | ./xpn_docker.sh stop          | ./xpn_docker.sh stop         |
     |                               |                               |                              |
      ----------------------------------------------------------------------------------------------


   * Examples of benchmarks with XPN Ad-Hoc:

      ----------------------------------------------------------------------------------------------
     |            MDtest                              |                   IOR                       |
      ----------------------------------------------------------------------------------------------
     |                                                |                                             |
     | : 1. To start 3 containers,                    | : 1. To start 3 containers,                 |
     | : 2. sleep 5 seconds,                          | : 2. sleep 5 seconds,                       |
     | : 3. work from container 1,                    | : 3. work from container 1,                 |
     | : 4. and stop all containers                   | : 4. and stop all containers                |
     |                                                |                                             |
     | ./xpn_docker.sh \                              | ./xpn_docker.sh \                           |
     |     start 3 \                                  |     start 3 \                               |
     |     sleep 5 \                                  |     sleep 5 \                               |
     |     exec 1 "./benchmark/xpn-mpi-mdtest.sh" \   |     exec 1 "./benchmark/xpn-mpi-ior.sh" \   |
     |     stop                                       |     stop                                    |
     |                                                |                                             |
      ----------------------------------------------------------------------------------------------


   * Examples of Ad-Hoc XPN with Apache Spark:

      ----------------------------------------------------------------------------------------------
     |                                     Apache Spark                                             |
      ----------------------------------------------------------------------------------------------
     |                                                                                              |
     | : 1. To start 3 containers                                                                   |
     | ./xpn_docker.sh start 3                                                                      |
     | ./xpn_docker.sh sleep 5                                                                      |
     |                                                                                              |
     | : 2. Work from container 1                                                                   |
     | ./xpn_docker.sh exec 1 ./spark/quixote-local.sh                                              |
     | ./xpn_docker.sh exec 1 ./spark/quixote-xpn.sh                                                |
     |                                                                                              |
     | : 3. Stop all containers                                                                     |
     | ./xpn_docker.sh stop                                                                         |
     |                                                                                              |
      ----------------------------------------------------------------------------------------------


Using xpn-docker
----------------

      ------------------------------------------------------------------------------------------------
     |          Action                                                      |         Command         |
      ------------------------------------------------------------------------------------------------
     | First time + "each time ./docker/dockerfile is updated"              | ./xpndocker.sh build    |
      ------------------------------------------------------------------------------------------------
     |                        | To spin up 3 containers                     | ./xpndocker.sh start 3  |
     |                        | To get into container 1                     | ./xpndocker.sh bash 1   |
     | Work session           | To exit from container                      | exit                    |
     |                        | To spin down all containers                 | ./xpndocker.sh stop     |
      ------------------------------------------------------------------------------------------------
     | Options for debugging  | To check running containers                 | ./xpndocker.sh status   |
     |                        | To get the containers internal IP addresses | ./xpndocker.sh network  |
      ------------------------------------------------------------------------------------------------

Please beware of:

   Any modification outside the "/work" directory will be discarded on container stopping.
   Please make a backup of your work "frequently" (just in case).
   You might need to use "sudo" before ./xpn_docker.sh if your user doesn't belong to the docker group
       It could be solved by using "sudo usermod -aG docker ${USER}"


Authors
-------

 :: Félix García-Carballeira
 :: Alejandro Calderón Mateos
 :: Diego Camarmas Alonso
 :: Dario Muñoz Muñoz
 :: Elias del Pozo Puñal


