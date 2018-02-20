#!/bin/bash

# install environment for go development

source env.sh

mkdir -p $DEV_PATH
ln -s $DEV_PATH $HOME/dev

install_all()
{
  for prefix in `0 1 2 3 4 5`; do
    for n in `ls conf.d/$prefix-*`; do
      conf.d/$n
    done
  done
}
install_all
