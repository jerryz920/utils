#!/bin/bash

# install environment for go development


export WORKDIR=${1:-`pwd`}
export GOPATH=$HOME/go
export GOROOT=$HOME/goroot
export PATH=$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/


GO_VERSION=1.9.2

update_repo()
{
  sudo apt-get update
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
  gocode set propose-builtins true
  gocode close # just in case
}

install_base()
{
  update_repo
  sudo apt-get install -y build-essential cmake make clang cscope
  sudo apt-get install -y python-dev libpython-dev
  sudo apt-get install -y vim git curl wget
  sudo apt-get install -y python-dev libpython-dev build-essentials cmake make
  sudo apt-get install -y python-pip python-jedi python-virtualenv
  sudo apt-get install -y bmon strace gdb valgrind faketime linux-tools-common
  configure_go
}

install_casablance()
{
  mkdir -p $HOME/tmp
  cd $HOME/tmp
  apt-get install -y libboost-all-dev libssl-dev cmake3 git g++
  mkdir -p net
  cd net
  git clone https://github.com/jerryz920/cpprestsdk.git casablanca
  cd casablanca/Release
  mkdir -p build.release && cd build.release
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make -j
  make install
  cd $HOME/tmp
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
	git config credential.helper 'cache --timeout=300'
}


modify_origin()
{
  git remote rename origin upstream
  git remote add origin https://github.com/jerryz920/$1
  git remote add fork https://github.com/jerryz920/$1
}

configure_workspace()
{
  # setup kubernetes
  go get github.com/kubernetes/kubernetes
  cd $GOPATH/src/github.com/kubernetes/kubernetes
  modify_origin kubernetes
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
  go get github.com/jerryz920/utils
  go get github.com/jerryz920/hadoop
  go get github.com/jerryz920/libport
}

install_base
install_libs
configure_vim
configure_git
configure_workspace
