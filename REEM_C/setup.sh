#!/bin/bash
set -eu -o pipefail

if [ ! -x "$(which setup_tools.sh)" ] ; then
    echo "==> File setup_tools.sh not found."
    exit 1
else
    # Setup the parent image
    echo "==> Configuring the parent image"
    source /usr/sbin/setup_tools.sh
    echo "==> Parent tools image configured"
fi

# Setup the custom bashrc
echo "==> Including additional bashrc configurations"
cp /usr/etc/skel/bashrc-dev /home/$USERNAME/.bashrc-dev
chown ${USERNAME}:${USERNAME} /home/$USERNAME/.bashrc-dev
echo "==> Putting bashrc into bashrc user"
echo "source /home/$USERNAME/.bashrc-dev" >> /home/${USERNAME}/.bashrc
echo "==> Putting bashrc into bashrc root"
echo "source /home/$USERNAME/.bashrc-dev" >> /root/.bashrc

echo "==> Change .local and .config permissions"
# Change the permissions of .local and .config
#[ -d /home/${USERNAME}/.local ] && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local
#[ -d /home/${USERNAME}/.config ] && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
