#!/bin/bash

# install python dev

export WORKDIR=${1:-`pwd`}

update_repo()
{
  sudo apt-get update
}


install_base()
{
  update_repo
  sudo apt-get install -y python-dev libpython-dev build-essentials cmake make
  sudo apt-get install -y python-pip python-jedi python-virtualenv
  sudo apt-get install -y vim git curl
}


configure_vim()
{
  mkdir -p ~/.vim/bundle
  git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  cp $WORKDIR/python/vimrc ~/.vimrc
  vim +PluginInstall +qall
}

update_repo
install_base
configure_vim
