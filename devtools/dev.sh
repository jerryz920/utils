#!/bin/bash

# install environment for go development


export WORKDIR=${1:-`pwd`}
export GOPATH=$HOME/go
export GOROOT=$HOME/goroot
export PATH=$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/

DEV_PATH=/opt/dev
DEV_DISK=/dev/mapper/local-dev
mkdir -p $DEV_PATH
mount $DEV_DISK $DEV_PATH
if [ $? -ne 0 ]; then
  echo "do not use dev path"
  export NO_DEV_PATH=1
else
  export NO_DEV_PATH=0
fi
GO_VERSION=1.9.2
PROTOBUF_VERSION="v3.5.1"
SCALA_VERSION=2.12.4

update_repo()
{
  sudo apt-get update
}

install_protobuf()
{
  go get -u github.com/google/protobuf
  cd $GOPATH/src/github.com/google/protobuf/
  ./autogen.sh
  ./configure.sh
  make -j 4
  sudo make install
  cd $WORKDIR
}

configure_go()
{
  mkdir -p $HOME/dev $HOME/goroot
  wget https://redirector.gvt1.com/edgedl/go/go$GO_VERSION.linux-amd64.tar.gz
  tar xf go$GO_VERSION.linux-amd64.tar.gz -C $HOME/goroot
  mv $HOME/goroot/go/* $HOME/goroot/
  rm -f go$GO_VERSION.linux-amd64.tar.gz
  cp $WORKDIR/general/bashrc ~/.bashrc
  # install go tools
  go get -u github.com/nsf/gocode
  go get -u google.golang.org/grpc
  go get -u github.com/golang/protobuf/protoc-gen-go

  install_protobuf $PROTOBUF_VERSION
  gocode set propose-builtins true
  gocode close # just in case
}

install_base()
{
  update_repo
  sudo apt-get install -y build-essential cmake make clang cscope autoconf
  sudo apt-get install -y python-dev libpython-dev
  sudo apt-get install -y vim git curl wget
  sudo apt-get install -y python-dev libpython-dev build-essentials cmake make
  sudo apt-get install -y python-pip python-jedi python-virtualenv
  sudo apt-get install -y bmon strace gdb valgrind faketime linux-tools-common
  sudo apt-get install -y libcrypto++-dev maven
  # only 2.0 supported on ubuntu 16.04
  #sudo apt-get install -y protobuf-compiler protobuf-c-compiler 
  configure_go
}

install_scala()
{
  echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
  sudo apt-get update
  sudo apt-get install sbt
  cd $WORKDIR
  wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb
  sudo dpkg -i scala-${SCALA_VERSION}.deb
  rm -f scala-${SCALA_VERSION}.deb
}

install_casablance()
{
  apt-get install -y libboost-all-dev libssl-dev cmake3 git g++
  go get github.com/jerryz920/cpprestsdk
  cd $GOPATH/src/github.com/jerryz920/cpprestsdk/Release
  git checkout dev
  mkdir -p build.release && cd build.release
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make -j 8
  make install
}

install_docker()
{

  # provision space
  if [ $NO_DEV_PATH -eq 0 ]; then
    sudo mkdir $DEV_PATH/docker
    sudo ln -s $DEV_PATH/docker /var/lib/docker
  fi
  sudo apt-get remove -y docker docker-engine docker.io
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  sudo apt-get update
  sudo apt-get install docker-ce
}

install_libs()
{
  install_casablance
}

configure_vim()
{

  sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git libpq-dev python-tox libffi-dev libxslt1-dev

  sudo apt-get install -y cmake

  mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone https://github.com/vim/vim.git
  cd vim
  git checkout v7.4.2367 -b v74
  ./configure --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp \
    --enable-pythoninterp \
    --enable-python3interp \
    --enable-perlinterp \
    --enable-luainterp \
    --enable-gui=gtk2 --enable-cscope --prefix=/usr
  #make VIMRUNTIMEDIR=/usr/share/vim/vim80
  make -j 5
  make install
  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
  sudo update-alternatives --set editor /usr/bin/vim
  sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
  sudo update-alternatives --set vi /usr/bin/vim
  cd $WORKDIR

  mkdir -p ~/.vim/bundle
  if ! [ -d ~/.vim/bundle/Vundle.vim ] ; then
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  fi
  cp $WORKDIR/general/vimrc ~/.vimrc
  vim +PluginInstall +qall
  vim +GoInstallBinaries +qall
  cd $HOME/.vim/bundle/YouCompleteMe
  python install.py --clang-completer --gocode-completer
  cd $WORKDIR
  cp $WORKDIR/go/ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py
}

# in case we have forgotten
configure_git()
{
  git config --global user.name "Yan Zhai"
  git config --global user.email zhaiyan920@gmail.com
  git config --global credential.helper 'cache --timeout=600'
  git config --global push.default current
}



modify_origin()
{
  git remote rename origin upstream
  git remote add origin https://github.com/jerryz920/$1
  git remote add fork https://github.com/jerryz920/$1
  git checkout --track origin/dev
}

configure_workspace()
{
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
  cd $GOPATH/src/github.com/docker/machine
  modify_origin machine

  go get github.com/jerryz920/linux
  go get github.com/jerryz920/boot2docker
  git checkout --track origin/dev
  go get github.com/jerryz920/utils
  go get github.com/jerryz920/hadoop
  git checkout --track origin/tapcon
  go get github.com/jerryz920/libport
}

install_my_arsenal()
{
  sudo $GOPATH/src/github.com/jerryz920/utils/library/install_lib.sh
}

install_base
install_libs
install_docker
configure_vim
configure_git
configure_workspace
install_my_arsenal
install_scala
