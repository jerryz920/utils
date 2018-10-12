#!/bin/bash

mkdir -p $GOROOT
wget https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
tar xf go$GO_VERSION.linux-amd64.tar.gz -C $GOROOT

# PATH might be overwritten even if we pass -E in sudo...
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
mv $GOROOT/go/* $GOROOT/
ln -s $GOROOT $HOME/goroot
rm -f go$GO_VERSION.linux-amd64.tar.gz
cp $WORKDIR/docker/general/bashrc ~/.bashrc
# install go tools
go get -u github.com/nsf/gocode
gocode set propose-builtins true
gocode close # just in case
