#!/bin/bash

pipinstall() {
  pip install $1
  pip3 install $1
}

pipinstall NetworkX
pipinstall ipaddress
pipinstall netaddr

