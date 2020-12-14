ARG from=fjandrad/tools-pal:latest
FROM ${from}

ENV CMAKE_GENERATOR=Ninja
ENV ROS_DISTRO kinetic
# Misc setup of the image
# =======================

# Include a custom bashrc
COPY bashrc /usr/etc/skel/bashrc-dev
COPY bashrc-colors /usr/etc/skel/bashrc-colors
COPY bashrc-functions /usr/etc/skel/bashrc-functions

# Include an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint_development.sh
COPY setup.sh /usr/sbin/setup_development.sh
RUN chmod 755 /usr/sbin/entrypoint_development.sh
RUN chmod 755 /usr/sbin/setup_development.sh
ENTRYPOINT ["/usr/sbin/entrypoint_development.sh"]
CMD ["bash"]
