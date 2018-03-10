#!/bin/bash

mkdir -p $GOROOT
wget https://redirector.gvt1.com/edgedl/go/go$GO_VERSION.linux-amd64.tar.gz
tar xf go$GO_VERSION.linux-amd64.tar.gz -C $GOROOT
mv $GOROOT/go/* $GOROOT/
ln -s $GOROOT $HOME/goroot
rm -f go$GO_VERSION.linux-amd64.tar.gz
cp $WORKDIR/general/bashrc ~/.bashrc
# install go tools
go get -u github.com/nsf/gocode
gocode set propose-builtins true
gocode close # just in case
