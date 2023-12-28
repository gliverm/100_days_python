# ------------------------------
# Multistage Docker File
# ------------------------------
# ------------------------------
# IMAGE: Target 'base' image
# docker build --file Dockerfile --target base -t pymntos-base .
# docker run -it --rm --name pymntos-base pymntos-base
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
# docker build --file Dockerfile --target pythonbase -t pymntos-pythonbase .
# docker run -it --rm pymntos-pythonbase
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
# Upgrade package management tools to latest
# hadolint ignore=DL3013
RUN echo "===> Installing pip ..." && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade pip && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade setuptools wheel pyinstaller && \
    python$PYTHON_VERSION -m pip install --no-cache-dir --upgrade pipenv && \
    python$PYTHON_VERSION -m pip list

# ------------------------------
# IMAGE: Target 'dev' for code development - no Python pkgs loaded
# docker build --file Dockerfile --target dev -t pymntos-dev .
# docker run -it --rm pymntos-dev
# docker container run -it -d -v pymntos-dev:/development -v ~/.ssh:/root/ssh -v ~/.gitconfig:/root/.gitconfig pymntos-dev
# docker container run -it -v pymntos-dev:/development -v ~/.ssh:/root/ssh -v ~/.gitconfig:/root/.gitconfig pymntos-dev
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
# docker build --file Dockerfile --target qa -t pymntos-qa .
# docker run -i --rm -v ${PWD}:/code pymntos-qa:test pylint --exit-zero --rcfile=setup.cfg **/*.py
# docker run -i --rm -v ${PWD}:/code pymntos-qa:test flake8 --exit-zero
# docker run -i --rm -v ${PWD}:/code pymntos-qa:test bandit -r --ini setup.cfg
# docker run -i --rm -v $(pwd):/code -w /code pymntos-qa:test black --check --exclude pymntos/tests/ pymntos/ || true
# docker run -i --rm -v ${PWD}:/code pymntos-unittest:test pytest --with-xunit --xunit-file=pyunit.xml --cover-xml --cover-xml-file=cov.xml pymntos/tests/*.py
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

# ------------------------------
# IMAGE: Target 'builder' builds production app utilizing pipenv
# docker build --file Dockerfile --target builder -t pymntos-builder .
# docker run -it --rm pymntos-builder sh
# ------------------------------
FROM pythonbase as builder
RUN echo "===> Installing specific python package versions ..."
WORKDIR /
COPY Pipfile .
COPY Pipfile.lock .
RUN pipenv install --system --deploy
COPY ./app /app
RUN echo "===> Building original ponflap application runtime ..." && \
    pyinstaller \
        --onefile \
        app/ponflap.py && \
    ls && \
    ls dist/ponflap
RUN echo "===> Building toolbox application runtime . . ." && \
    pyinstaller \
        --onefile \
        app/toolbox.py && \
    ls && \
    ls dist/toolbox

# ------------------------------
# IMAGE: Target 'app' for final production app build
# docker build --file Dockerfile --target app -t pymntos-app .
# docker run -it --rm pymntos-app sh
# Using volumnes with a username different than host is problematic: https://github.com/moby/moby/issues/2259
# ------------------------------
FROM base as app
WORKDIR /
RUN echo "===> Install ponflap ..."
COPY --from=builder /dist/ponflap /opt/ponflap
RUN echo "===> Install toolbox ..."
COPY --from=builder /dist/toolbox /opt/toolbox
ENV PATH "$PATH:/opt"
WORKDIR /toolbox
# Note: /config : Location of app configuration files
RUN echo "===> Setting working directories..." && \
    mkdir /toolbox/config && \
    mkdir /toolbox/project
VOLUME /toolbox/config
VOLUME /toolbox/project
RUN ["toolbox", "--help"]
CMD ["toolbox", "--help"]