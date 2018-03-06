#!/bin/bash

sudo apt-get install -y libboost-all-dev libssl-dev git g++
go get github.com/jerryz920/cpprestsdk
cd $GOPATH/src/github.com/jerryz920/cpprestsdk/Release
git checkout -b dev origin/dev
mkdir -p build.release && cd build.release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j 8 install
