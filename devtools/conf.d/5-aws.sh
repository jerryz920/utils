#!/bin/bash

apt-get install libyaml-dev libyaml-dev-cpp
pip install awscli --upgrade --user

find $HOME -name aws_bash_completer -exec sudo cp {} /etc/bash_completion.d/ \;

