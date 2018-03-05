#!/bin/bash

# provision space
if [ $NO_DEV_PATH -eq 0 ]; then
  sudo mkdir $DEV_PATH/docker
  sudo ln -s $DEV_PATH/docker /var/lib/docker
fi
sudo apt-get remove -y docker docker-engine docker.io
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
