#!/bin/bash

sudo docker/conf.d/0-base.sh
sudo docker/conf.d/0-docker.sh
sudo cp bin/workon bin/buildenv /usr/local/bin/
buildenv $1

