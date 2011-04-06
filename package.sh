#!/bin/bash

. ./config.rc

install_rvm
fpm -s dir -t deb -C ./build -n rvm -v $(date +%Y%m%d%H%M%S) opt/rvm
