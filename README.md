# 100_days_python

Simple collection of python code explored.  Using a Docker file to keep it a bit more portable.

### Prerequisites

* GIT
* Docker
* Visual Studio Code IDE

### How to bring up Development Environment

1. From a new VSCode window open the project.
2. VSCode should ask to re-open project in a container.  If not click on lower left green corner to re-open in a container.
3. After the container is up select the python interpreter.  More than likely the recommended value is highlighted.  If not close down the VSCode window and re-open in the container.

### Notes to self while developing Dockerfile

* Want to run Python3 version higher than distro
* Problem: bash: add-apt-repository: command not found
  * apt-get update
  * apt-get install software-properties-common
  * apt-get update
* add-apt-repository ppa:deadsnakes/ppa
*
