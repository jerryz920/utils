#!/bin/bash

sudo conf.d/0-docker.sh
sudo cp bin/workon bin/buildenv /usr/local/bin/
buildenv

