#!/bin/bash
go get -u github.com/kardianos/govendor

# Riak client, distributed k/v. Need to install and configure riak first.
go get github.com/basho/riak-go-client


# interval tree
go get github.com/biogo/store/interval
go get github.com/gorilla/mux
go get github.com/sirupsen/logrus
