export DEV_PATH=/opt/dev
export DEV_DISK=/dev/mapper/local-dev
export WORKDIR=${1:-`pwd`}
export GOPATH=$DEV_PATH/go
export GOROOT=$DEV_PATH/goroot
export PATH=$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/
export GO_VERSION=1.9.2
export PROTOBUF_VERSION="v3.5.1"
export SCALA_VERSION=2.12.4

