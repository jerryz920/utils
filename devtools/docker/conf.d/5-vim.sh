#!/bin/bash
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
mkdir -p ~/.vim/
cp $WORKDIR/general/ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py
cp $WORKDIR/general/vimrc ~/.vimrc
