export DEV_PATH=/openstack/
export DEV_DISK=/dev/mapper/local-dev
export WORKDIR=${1:-`pwd`}
export GOPATH=/openstack/go
export GOROOT=/openstack/goroot
export PATH=$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/
export GO_VERSION=1.9.2
export PROTOBUF_VERSION="v3.5.1"
export SCALA_VERSION=2.12.4

