#!/bin/bash

docker commit dev dev:${1:-latest}
