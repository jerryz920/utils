#!/bin/bash

# install environment for go development

source env.sh $1

mkdir -p $DEV_PATH
ln -s $DEV_PATH $HOME/dev

install_all()
{
  for prefix in 0 1 2 3 4 5; do
    for n in `ls conf.d/$prefix-*`; do
      ./$n
    done
  done
}
install_all

#conf.d/0-base.sh
#conf.d/1-go.sh
##conf.d/2-docker.sh
#conf.d/2-protobuf.sh
#conf.d/5-aws.sh
#conf.d/5-casablance.sh
#conf.d/5-config.sh
#conf.d/5-gotool.sh
##conf.d/5-haskell.sh
#conf.d/5-myrepo.sh
##conf.d/5-scala.sh
#conf.d/5-vim.sh
