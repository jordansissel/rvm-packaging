#!/bin/bash
#

. ./config.rc

if [ ! -f $rvm_path/scripts/rvm ] ; then
  # install rvm and retry.
  echo "RVM not found; installing now to $rvm_path"
  install_rvm
  exec bash $0 "$@"
fi

# Run this in a subshell so the rvm loading doesn't infect our current shell.
(
  . $rvm_path/scripts/rvm
  rvm list known
)

