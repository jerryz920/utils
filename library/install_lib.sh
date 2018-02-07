#!/bin/bash

SCRIPT_PATH=`readlink -f $0`
SCRIPT_HOME=`dirname $SCRIPT_PATH`
cd $SCRIPT_HOME/cxx/
bash install_lib.sh
