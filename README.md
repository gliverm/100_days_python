# pymntos_basic_docker

Simple Docker demo for PyMNtos January 2024 presentation

The intention of this repo is to be used to demonstrate the basics of a simple Python project developed inside a Docker container.  The audience is beginner-level.  The readme will be a playbook leading others thru points-of-interest to create discussion points.  The intention is to not explain everything here but to provide a jump-start.

### Prerequisites

* GIT
* Docker
* Visual Studio Code IDE

### Useful References

* https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
* 

## Points-of-Interest

### Dockerfile

* Multistage docker file
* Commands: ARG, FROM, LABEL, ENV, RUN, CMD
* Alternative method comments
  * Use DockerHub python file to obtain different versions
  * Considerations: 3rd party software, final size of image, overall control
* Comments at each stage to: describe stage, build for target stage, run target stage
* Some stages will have a RUN command to test 'lights-on' will the container work
* Linting done with Hadolint
  * linting - process of performing static analysis on source code to flag patterns that might cause errors or other problems
  * care when ignoring linting issues
    * want most up-to-date system and ok with risks
    * want most up-to-date python linters and ok with risks
* Python Install
* * Can use the default distro (3.10)
  * In this case chose to install (3.11)
  *
