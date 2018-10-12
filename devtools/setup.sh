#!/bin/bash

source docker/env.sh $1
sudo docker/conf.d/0-base.sh
sudo docker/conf.d/0-docker.sh
sudo -E docker/conf.d/1-go.sh
sudo -E docker/conf.d/5-config.sh
sudo -E docker/conf.d/5-vim.sh
sudo cp bin/workon bin/buildenv /usr/local/bin/
buildenv $1

