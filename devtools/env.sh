export DEV_PATH=${1:-/opt/}
export DEV_DISK=/dev/mapper/local-dev
export WORKDIR=`pwd`
export GOPATH=$DEV_PATH/go
export GOROOT=$DEV_PATH/goroot
export PATH=$HOME/.local/bin:$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/
export LD_LIBRARY_PATH=$HOME/.local/lib:/usr/local/bin/
export GO_VERSION=1.9.2
export PROTOBUF_VERSION="v3.5.1"
export SCALA_VERSION=2.12.4

