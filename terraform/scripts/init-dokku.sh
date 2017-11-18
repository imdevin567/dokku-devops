#!/bin/bash

set -e

# Install prerequisites
apt-get update -qq > /dev/null
apt-get install -qq -y apt-transport-https

# Set default options for dokku
echo "dokku dokku/vhost_enable boolean true" | debconf-set-selections
echo "dokku dokku/web_config boolean false" | debconf-set-selections
echo "dokku dokku/hostname string $HOSTNAME" | debconf-set-selections
echo "dokku dokku/key_file string $HOME/.ssh/authorized_keys" | debconf-set-selections

# Install docker
wget -nv -O - https://get.docker.com/ | sh

# Install dokku
wget -nv -O - https://packagecloud.io/gpg.key | apt-key add -
echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/dokku.list
apt-get update -qq > /dev/null
apt-get install -qq -y dokku
dokku plugin:install-dependencies --core
