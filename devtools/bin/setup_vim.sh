#!/bin/bash
export GOPATH=$HOME/dev/go
export GOROOT=$HOME/goroot
export PATH=$HOME/.local/bin:$PATH:$HOME/bin:$GOPATH/bin:$GOROOT/bin/
export EDITOR=vim

wait_timeout()
{
  local p=$1
  echo "wait for PID $p, cmd = "
  cat /proc/$p/cmdline
  echo
  local timeout=$2
  local should_kill=1
  while [ $timeout -ne 0 ]; do
    sleep 1
    if ! test -d /proc/$p ; then
      echo "PID $p finishes"
      should_kill=0
      break
    fi
    timeout=$((timeout-1))
  done
  if [ $should_kill -eq 1 ]; then
    cat /proc/$p/cmdline
    echo "PID $p timeout, kill" 
    kill -KILL $p
  fi
}

mkdir -p ~/.vim/bundle
if ! [ -d ~/.vim/bundle/Vundle.vim ] ; then
  git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall
vim +GoInstallBinaries +qall
cd $HOME/.vim/bundle/YouCompleteMe
python install.py --clang-completer --gocode-completer

if [[ x"$1" == x ]]; then
  # in Docker, commit the change
  docker commit develop dev
fi
