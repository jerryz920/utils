#!/bin/bash

apt-get install libyaml-dev libyaml-cpp-dev
pip install awscli --upgrade --user

find $HOME -name aws_bash_completer -exec sudo cp {} /etc/bash_completion.d/ \;

wget https://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
sudo unzip ec2-ami-tools.zip -d /usr/local/
sudo mv /usr/local/ec2-ami* /usr/local/ec2
export EC2_AMITOOL_HOME=/usr/local/ec2/
export PATH=$EC2_AMITOOL_HOME/bin:$PATH
