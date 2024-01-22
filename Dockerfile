# ------------------------------
# Multistage Docker File 
# Only for building of dev environment
# Do not anticpate this will ever turn into a real app
# ------------------------------
# ------------------------------
# IMAGE: Target 'base' image
# docker build --file Dockerfile --target base -t daysofpython-base .
# docker run -it --rm daysofpython-base
# ------------------------------
ARG UBUNTU_RELEASE=22.04
FROM ubuntu:${UBUNTU_RELEASE} AS base
LABEL maintainer="Gayle Livermore <gayle.livermore@gmail.com>"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV LC_CTYPE="C.UTF-8"
ENV TZ=America/Chicago
ENV SHELL /bin/bash
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# hadolint ignore=DL3008
RUN echo "===> Adding build dependencies..."  && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends --yes \
    git \
    libfontconfig1 \
    ca-certificates \
    wget \
    curl && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Lights on install check
RUN ["git", "--version"]

# ------------------------------
# IMAGE: Target 'pythonbase' for base of all images that need Python
# docker build --file Dockerfile --target pythonbase -t daysofpython-pythonbase .
# docker run -it --rm daysofpython-pythonbase
# ------------------------------
FROM base AS pythonbase
ARG PYTHON_VERSION=3.11
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# Use latest python related packages
# hadolint ignore=DL3008
RUN echo "===> Updating ppa for Python ..." && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends --yes \
    software-properties-common \
    gpg-agent && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt-get install --no-install-recommends --yes \
    python$PYTHON_VERSION \
    build-essential \
    openssh-client \
    python3-dev \
    python3-pip \
    python3-pycurl && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo "===> Setting python version " && \
    update-alternatives --install /usr/bin/python python /usr/bin/python$PYTHON_VERSION 1
# Upgrade package management tools to latest
# hadolint ignore=DL3013
RUN echo "===> Installing pip ..." && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade pip && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade setuptools wheel pyinstaller && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade pipenv && \
    python$PYTHON_VERSION -m pip list

# ------------------------------
# IMAGE: Target 'dev' for code development - no Python pkgs loaded
# docker build --file Dockerfile --target dev -t daysofpython--dev .
# docker run -it --rm daysofpython--dev
# docker container run -it -d -v daysofpython--dev:/development -v ~/.ssh:/root/ssh -v ~/.gitconfig:/root/.gitconfig daysofpython--dev
# docker container run -it -v daysofpython--dev:/development -v ~/.ssh:/root/ssh -v ~/.gitconfig:/root/.gitconfig daysofpython--dev
# ------------------------------
FROM pythonbase AS dev
ARG PROJECT_DIR=/development
RUN echo "===> creating working directory..."  && \
    mkdir -p $PROJECT_DIR
WORKDIR $PROJECT_DIR

# ------------------------------
# IMAGE: Target 'qa' for static code analysis and unit testing
# Future: Consider benefit lint shell script in addition to below
# Install the latest static code analysis tools
# docker build --file Dockerfile --target qa -t daysofpython--qa .
# docker run -i --rm -v ${PWD}:/code daysofpython--qa:test pylint --exit-zero --rcfile=setup.cfg **/*.py
# docker run -i --rm -v ${PWD}:/code daysofpython--qa:test flake8 --exit-zero
# docker run -i --rm -v ${PWD}:/code daysofpython--qa:test bandit -r --ini setup.cfg
# docker run -i --rm -v $(pwd):/code -w /code daysofpython--qa:test black --check --exclude daysofpython-/tests/ daysofpython-/ || true
# docker run -i --rm -v ${PWD}:/code daysofpython--unittest:test pytest --with-xunit --xunit-file=pyunit.xml --cover-xml --cover-xml-file=cov.xml daysofpython-/tests/*.py
# ------------------------------
FROM pythonbase AS qa
WORKDIR /
COPY Pipfile .
COPY Pipfile.lock .
# Upgrade linting tools to latest 
# hadolint ignore=DL3013
RUN pipenv install --dev --deploy --system && \
    pip install --upgrade --no-cache-dir pylint flake8 bandit black
WORKDIR /code/

