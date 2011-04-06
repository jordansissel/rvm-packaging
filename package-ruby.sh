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
  echo "RVM not found; installing now to $rvm_path"
  install_rvm
  exec bash $0 "$@"
fi

# Run this in a subshell so the rvm loading doesn't infect our current shell.
(
  . $rvm_path/scripts/rvm
  rvm use $wantruby || rvm install $wantruby
)

rubyinfo="$(. $rvm_path/scripts/rvm; rvm use $wantruby > /dev/null; rvm info | sed -ne '/^  ruby:/,/^ *$/p')"
ruby="$(echo "$rubyinfo" | awk -F\" '/ interpreter:/ { print $2 }')"
version="$(echo "$rubyinfo" | awk -F\" '/ version:/ { print $2 }')"
rubyname="$(. $rvm_path/scripts/rvm; rvm use $wantruby > /dev/null; rvm current)"

echo "rubyinfo: $rubyinfo"
echo "ruby: $ruby"
echo "version: $version"
echo "name: $rubyname"

echo "patching rvm scripts to remove path '$DESTDIR/'"
find $DESTDIR/$PREFIX/{wrappers,environments} -type f -print0 \
  | xargs -0n1 sed -i -e "s,$DESTDIR/,,g"
find $DESTDIR/$PREFIX/rubies/${rubyname} -type f -name '*.rb' -print0 \
  | xargs -0n1 sed -i -e "s,$DESTDIR/,,g"
find $DESTDIR/$PREFIX/rubies/${rubyname} -type f -name '*.h' -print0 \
  | xargs -0n1 sed -i -e "s,$DESTDIR/,,g"
for i in $DESTDIR/$PREFIX/{rubies/${rubyname}/bin,wrappers/${rubyname}}/{erb,gem,irb,rake,rdoc,ri,testrb} ; do
  sed -i -e "s,$DESTDIR/,,g" $i
done

echo "Packaging up $ruby-$version"
fpm -s dir -t deb -C ./build -n rvm-${ruby}-${version} -v ${version}-1 \
  opt/rvm/{gems,rubies,wrappers,environments,log,src,bin}/${rubyname}
