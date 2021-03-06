ARG from=diegoferigo/development:nvidia-master
FROM ${from}

# Create a new runtimeusers group (it might already exist)
RUN groupadd runtimeusers || true

ENV RL_DIR=/rl
ENV RL_INSTALL=${RL_DIR}/local
ENV RL_SOURCES=${RL_DIR}/sources
ENV PATH=${RL_INSTALL}/bin:${PATH}
ENV CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:${RL_INSTALL}

RUN mkdir -p ${RL_SOURCES}

ENV CMAKE_GENERATOR="Ninja"
ENV SOURCES_BUILD_TYPE="RelWithDebInfo"
ENV IGN_INSTALL_PREFIX_PATH="/usr"

# =================
# Python VirtualEnv
# =================

ENV VIRTUAL_ENV=/rl/venv
ENV PATH=${VIRTUAL_ENV}/bin:$PATH

RUN pip3 install virtualenv &&\
    virtualenv ${VIRTUAL_ENV} &&\
    pip3 install \
        jupyter \
        docker \
        PyYAML \
        matplotlib \
        pytest \
        gym \
        numpy \
        setuptools_scm \
        pybullet \
        ray[debug,rllib,tune] gputil \
        torch torchvision \
        tensorboard tensorboardX \
        tensorflow tensorflow-probability \
        PyVirtualDisplay PILLOW imageio imageio-ffmpeg \
        sphinx sphinx-rtd-theme sphinx-autodoc-typehints \
        sphinx_fontawesome sphinx-multiversion breathe \
        &&\
    rm -r $HOME/.cache/pip &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# =======
# PyCharm
# =======

ARG PYCHARM_VER=2019.3.5
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        python-setuptools \
        python3-setuptools \
        libpython-dev \
        libpython3-dev \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /opt && mkdir pycharm && cd pycharm &&\
    curl -L https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VER}.tar.gz -o /opt/pycharm/installer.tgz &&\
    tar --strip-components=1 -xzf installer.tgz &&\
    rm installer.tgz &&\
    python2 /opt/pycharm/plugins/python-ce/helpers/pydev/setup_cython.py build_ext --inplace &&\
    python3 /opt/pycharm/plugins/python-ce/helpers/pydev/setup_cython.py build_ext --inplace &&\
    ln -s /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm

# ========
# iDynTree
# ========

# Use python bindings from fork
RUN cd ${RL_SOURCES} &&\
    git clone -b feature/numpy-and-ik --depth=1 https://github.com/diegoferigo/idyntree &&\
    mkdir -p idyntree/build &&\
    cd idyntree/build &&\
    cmake \
          -GNinja \
          -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
          -DIDYNTREE_SHARED_LIBRARY:BOOL=OFF \
          -DCMAKE_INSTALL_PREFIX=${RL_INSTALL} \
          -DIDYNTREE_USES_PYTHON:BOOL=ON \
          -DIDYNTREE_USES_PYTHON_VERSION=3.6 \
          -DPYTHON_EXECUTABLE=${VIRTUAL_ENV}/bin/python \
          -DPYTHON_NUMPY_INCLUDE_DIR:PATH=${VIRTUAL_ENV}/lib/python3.6/site-packages/numpy/core/include \
          -DIDYNTREE_USES_KDL:BOOL=OFF \
          -DYCM_USE_DEPRECATED=OFF \
          .. &&\
    cmake --build . --target install &&\
    find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${RL_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+
ENV PYTHONPATH=${RL_INSTALL}/lib/python3.6/site-packages:${PYTHONPATH}

# ============
# Common tools
# ============

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        apt-utils \
        gnupg \
        gnupg2 \
        apt-utils \
        ca-certificates \
        curl \
        lsb-release \
        software-properties-common \
        wget \
        libxml2-dev \
        python3-tk \
        ssh \
        &&\
    rm -rf /var/lib/apt/lists/*

# =================
# Development tools
# =================

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - &&\
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ `lsb_release -cs` main" &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        cmake-curses-gui \
        build-essential \
        gcc-8 \
        g++-8 \
        ninja-build \
        mercurial \
        python3-pip \
        xvfb \
        &&\
    rm -rf /var/lib/apt/lists/*

# =================
# Ignition Robotics
# =================

# https://ignitionrobotics.org/docs/citadel/install
# http://gazebosim.org/tutorials?tut=install_dependencies_from_source

# Install protobuf
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        libtool \
        autoconf \
        automake \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd ${RL_SOURCES} &&\
    git clone --depth 1 -b v3.7.0 https://github.com/google/protobuf &&\
    cd protobuf &&\
    git submodule update --init --recursive &&\
    ./autogen.sh &&\
    ./configure &&\
    make -j8 &&\
    make install

# Setup locales and timezone
ENV TZ=Europe/Rome
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get install -y --no-install-recommends locales locales-all tzdata &&\
    rm -rf /var/lib/apt/lists/* &&\
    echo "${TZ}" | tee /etc/timezone &&\
    dpkg-reconfigure --frontend noninteractive tzdata

ARG IGNITION_DEFAULT_CHANNEL="prerelease"
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-${IGNITION_DEFAULT_CHANNEL} `lsb_release -cs` main" > \
        /etc/apt/sources.list.d/gazebo-${IGNITION_DEFAULT_CHANNEL}.list &&\
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - &&\
    apt-get update &&\
    # Remove Gazebo Classic
    apt remove -y gazebo10 libgazebo10-dev libprotobuf-dev protobuf-compiler libprotobuf10 libprotobuf-lite10 &&\
    apt autoremove -y &&\
    # Install deps of Ignition Gazebo
    apt-get install -y --no-install-recommends \
        cmake freeglut3-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
        libdart6-collision-ode-dev libdart6-dev libdart6-utils-urdf-dev \
        libfreeimage-dev libgflags-dev libglew-dev libgts-dev libogre-1.9-dev libogre-2.1-dev \
        #libprotobuf-dev libprotobuf-dev libprotoc-dev \#
        libqt5core5a libswscale-dev libtinyxml2-dev libtinyxml-dev pkg-config \
        protobuf-compiler python qml-module-qt-labs-folderlistmodel \
        qml-module-qt-labs-settings qml-module-qtquick2 qml-module-qtquick-controls \
        qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-layouts \
        qml-module-qtqml-models2 qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev \
        ruby ruby-ronn uuid-dev libzip-dev libjsoncpp-dev libcurl4-openssl-dev libyaml-dev \
        libzmq3-dev libsqlite3-dev libwebsockets-dev \
        #swig \#
        ruby-dev \
        &&\
    rm -rf /var/lib/apt/lists/*

RUN pip3 install vcstool colcon-common-extensions &&\
    rm -r $HOME/.cache/pip

ENV CC="gcc-8"
ENV CXX="g++-8"
ARG IGN_SOURCES_DATE="20200528"
RUN mkdir -p ${RL_SOURCES}/workspace/src &&\
    cd ${RL_SOURCES}/workspace/src &&\
    wget https://raw.githubusercontent.com/robotology/gym-ignition/devel/.docker/tags.yaml &&\
    vcs import < tags.yaml &&\
    cd ${RL_SOURCES}/workspace &&\
    colcon graph &&\
    colcon build \
        --cmake-args \
        -G"$CMAKE_GENERATOR" \
        -DBUILD_TESTING:BOOL=OFF \
        -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} \
        -DCMAKE_INSTALL_PREFIX=${IGN_INSTALL_PREFIX_PATH} \
        --merge-install \
        &&\
    find ${RL_SOURCES}/workspace -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+
RUN echo "source ${RL_SOURCES}/workspace/install/setup.bash" >> /etc/bash.bashrc

# Fix permissions of the directories inside RL_DIR
RUN find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# =============
# Install Julia
# =============

ARG JULIA_VER=1.4.1
ENV DEVENV_PATH=${DEVENV_PATH}:/opt/julia/bin

RUN cd /tmp &&\
    wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VER%.*}/julia-${JULIA_VER}-linux-x86_64.tar.gz &&\
    cd /opt &&\
    tar xvf /tmp/julia-${JULIA_VER}-linux-x86_64.tar.gz &&\
    rm /tmp/julia-${JULIA_VER}-linux-x86_64.tar.gz &&\
    mv julia-${JULIA_VER} julia &&\
    /opt/julia/bin/julia --version

ARG ATOM_VERSION=v1.46.0
ARG ATOM_PKG_TMP=/tmp/atom_packages.txt
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fakeroot \
        gconf2 \
        gconf-service \
        git \
        gvfs-bin \
        libasound2 \
        libcap2 \
        libgconf-2-4 \
        libgcrypt20 \
        libgtk2.0-0 \
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libx11-xcb1 \
        libxkbfile1 \
        libxss1 \
        libxtst6 \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        policykit-1 \
        python \
        xdg-utils &&\
    rm -rf /var/lib/apt/lists/* &&\
    curl -L https://github.com/atom/atom/releases/download/${ATOM_VERSION}/atom-amd64.deb > /tmp/atom.deb && \
    dpkg -i /tmp/atom.deb && \
    rm -f /tmp/atom.deb && \
    echo "ink" >> ${ATOM_PKG_TMP} &&\ 
    echo "uber-juno" >> ${ATOM_PKG_TMP} &&\ 
    echo "tool-bar" >> ${ATOM_PKG_TMP} &&\
    echo "indent-detective" >> ${ATOM_PKG_TMP} &&\
    echo "latex-completions" >> ${ATOM_PKG_TMP} &&\
    echo "hyperclick" >> ${ATOM_PKG_TMP} &&\ 
    echo "language-julia" >> ${ATOM_PKG_TMP} &&\ 
    echo "julia-client" >> ${ATOM_PKG_TMP} &&\
    apm install --packages-file ${ATOM_PKG_TMP} &&\
    cp -r /root/.atom /opt/dotatom &&\
    find /opt/dotatom -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# TODO: these packages are not available to the user.
# Follow: https://discourse.julialang.org/t/how-does-one-set-up-a-centralized-julia-installation/13922/21
#RUN \
#    /opt/julia/bin/julia -e 'import Pkg; Pkg.add([\
#        "IJulia",\
#        "Plots",\
#        "PyPlot",\
#        "LaTeXStrings",\
#        ]);'

# =======================
# Install projects for RL
# =======================

# Install SWIG 4 from sources
ARG SWIG_REL="rel-4.0.1"
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        autotools-dev \
        automake \
        bison \
        libpcre3-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /tmp/ &&\
    git clone --depth 1 -b ${SWIG_REL} https://github.com/swig/swig.git &&\
    cd swig &&\
    sh autogen.sh &&\
    ./configure &&\
    make -j2 &&\
    make install &&\
    rm -r /tmp/swig

# =============
# FIX OWNERSHIP
# =============

RUN find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${RL_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# ====================
# Image initialization
# ====================

COPY setup.sh /usr/sbin/setup_rl.sh
COPY entrypoint.sh /usr/sbin/entrypoint_rl.sh
RUN chmod 755 /usr/sbin/setup_rl.sh
RUN chmod 755 /usr/sbin/entrypoint_rl.sh
ENTRYPOINT ["/usr/sbin/entrypoint_rl.sh"]
CMD ["bash"]
