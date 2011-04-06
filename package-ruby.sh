#!/bin/bash

wantruby=$1
if [ -z "$wantruby" ] ; then
  echo "Usage: $0 <ruby>"
  echo "Example: $0 jruby"
  exit 1
fi

. ./config.rc

if [ ! -f $rvm_path/scripts/rvm ] ; then
  # install rvm and retry.
  install_rvm
  exec bash $0 "$@"
fi

(
  . $rvm_path/scripts/rvm
  rvm use $wantruby || rvm install $wantruby
)

echo "patching rvm scripts to remove path '$DESTDIR/'"
find $DESTDIR/$PREFIX/{wrappers,environments} -type f -print0 \
  | xargs -0n1 sed -ie "s,$DESTDIR/,,g"

rubyinfo="$(. $rvm_path/scripts/rvm; rvm use $wantruby; rvm info | sed -ne '/^  ruby:/,/^ *$/p')"
ruby="$(echo "$rubyinfo" | awk -F\" '/ interpreter:/ { print $2 }')"
version="$(echo "$rubyinfo" | awk -F\" '/ version:/ { print $2 }')"

echo "Packaging up $ruby-$version"
fpm -s dir -t deb -C ./build -n rvm-${ruby} -v ${version}-1 \
  opt/rvm/{gems,rubies,wrappers,environments,log,src,bin}/${ruby}-${version}
