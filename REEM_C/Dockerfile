ARG from=fjandrad/tools-pal:latest
FROM ${from}

ENV CMAKE_GENERATOR=Ninja
ENV ROS_DISTRO kinetic
# Misc setup of the image
# =======================

ENV HCRL_DIR=/hcrl
ENV HCRL_INSTALL=${HCRL_DIR}/local
ENV HCRL_SOURCES=${HCRL_DIR}/sources
ARG HCRL_BIN=${HCRL_INSTALL}/bin

# Download all sources with git
# -----------------------------

RUN mkdir -p ${HCRL_SOURCES} &&\
    cd ${HCRL_SOURCES} &&\
    git clone https://github.com/AtsushiSakai/rosbag_to_csv.git # &&\
    #git clone https://git.uwaterloo.ca/hcrmi/lab/human-centred-robotics-lab/utilities_hcrl.git &&\
    #chgrp -R runtimeusers ${HCRL_DIR} && chmod -R g+rw ${HCRL_DIR}

## Install rosbag_to_csv
RUN add-apt-repository universe
RUN apt-get update &&\
    apt-get install -y pyqt4-dev-tools &&\
    rosdep init &&\
    rosdep update &&\
    rosdep install -r --ignore-src --from-paths ${HCRL_SOURCES}


    # setup keys
  #  RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
  #                  --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 &&\
  #      echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" \
  #          > /etc/apt/sources.list.d/ros-latest.list


  #  RUN apt-get update &&\
  #      apt-get install -y --no-install-recommends \
  #      python-pip \
  #    	python-vcstools \
  #      ros-$ROS_DISTRO-moveit-commander \
  #      python-rosdep \
  #  	  python-rosinstall \
  #    	python-catkin-tools \
  #      &&\
  #      rm -rf /var/lib/apt/lists/*

  #  RUN sudo python -m pip install 'pyassimp>=3.3.0,<3.4.0' --force-reinstall


# Include a custom bashrc
COPY bashrc /usr/etc/skel/bashrc-dev
COPY bashrc-colors /usr/etc/skel/bashrc-colors
COPY bashrc-functions /usr/etc/skel/bashrc-functions
COPY rosmaster_robot.env /usr/etc/rosmaster/rosmaster_robot.env
COPY rosmaster_localhost.env /usr/etc/rosmaster/rosmaster_localhost.env

# Include an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint_development.sh
COPY setup.sh /usr/sbin/setup_development.sh
RUN chmod 755 /usr/sbin/entrypoint_development.sh
RUN chmod 755 /usr/sbin/setup_development.sh
ENTRYPOINT ["/usr/sbin/entrypoint_development.sh"]
CMD ["bash"]
