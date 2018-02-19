#!/bin/bash

# install environment for go development

source env.sh

mkdir -p $DEV_PATH
mount $DEV_DISK $DEV_PATH
if [ $? -ne 0 ]; then
  echo "do not use dev path"
  export NO_DEV_PATH=1
  mkdir -p $HOME/dev/
else
  export NO_DEV_PATH=0
  ln -s $DEV_PATH $HOME/dev
fi

install_all()
{
  for prefix in `0 1 2 3 4 5`; do
    for n in `ls conf.d/$prefix-*`; do
      conf.d/$n
    done
  done
}
install_all
