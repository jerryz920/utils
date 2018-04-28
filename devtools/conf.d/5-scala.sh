#!/bin/bash
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt
cd $WORKDIR
wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb
sudo dpkg -i scala-${SCALA_VERSION}.deb
rm -f scala-${SCALA_VERSION}.deb
pip install riak # used by SAFE project
