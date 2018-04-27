#!/bin/bash

modify_origin()
{
  git remote rename origin upstream
  git remote add origin https://github.com/jerryz920/$1
  git remote add fork https://github.com/jerryz920/$1
  git fetch origin
  git checkout -b ${2:-dev} --track remotes/origin/${2:-dev}
}
# setup kubernetes
go get github.com/kubernetes/kubernetes
cd $GOPATH/src/github.com/kubernetes/kubernetes
modify_origin kubernetes

# kubernetes need special hack to navigate correctly as its original repository is k8s.io
mkdir -p $GOPATH/src/k8s.io/
ln -s $GOPATH/src/github.com/kubernetes/kubernetes $GOPATH/src/k8s.io/kubernetes

# setup docker
go get github.com/docker/docker
cd $GOPATH/src/github.com/docker/docker
modify_origin docker
# setup docker-machine
go get github.com/docker/machine
go get github.com/jerryz920/linux
go get github.com/jerryz920/boot2docker
cd $GOPATH/src/github.com/jerryz920/boot2docker
git checkout -b dev --track remotes/origin/dev
go get github.com/jerryz920/utils
go get github.com/jerryz920/hadoop
cd $GOPATH/src/github.com/jerryz920/hadoop
git checkout -b tapcon --track remotes/origin/tapcon
go get github.com/jerryz920/libport

sudo $GOPATH/src/github.com/jerryz920/utils/library/install_lib.sh
