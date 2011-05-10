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

# DESTDIR comes from 'config.rc'
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

# Mangle the 'ruby' binary to fix the RPATH (LD_RUN_PATH) stuff.
rubybin=$DESTDIR/$PREFIX/rubies/${rubyname}/bin/ruby
echo "Checking if we need to patch the ruby binary; $rubybin"
if readelf -d $rubybin | grep RPATH | grep -qF $DESTDIR  ; then
  echo "patching ruby binary to use correct library path"
  old_libpath=$(readelf -d $rubybin | grep RPATH | sed -re 's/.*\[(.*)\]/\1/')
  fixed_libpath=$(echo "$old_libpath" | sed -e "s,$DESTDIR/,,g")
  echo "Old: ${old_libpath}"
  echo "New: ${fixed_libpath}"
  export old_libpath
  export fixed_libpath
  # Replace the ld libpath with the fixed libpath, padded by nulls
  ruby -p -e '
    $_.gsub!(ENV["old_libpath"]) do |s|
      ENV["fixed_libpath"] + ("\0" * (ENV["old_libpath"].size - ENV["fixed_libpath"].size))
    end
  ' $rubybin > $rubybin.patched
fi


# skip the 'src' dir, too, we don't want it.

echo "Packaging up $ruby-$version"
iteration=2
fpm -s dir -t deb -C ./build -n rvm-${ruby}-${version} -v ${version}-${iteration} \
  opt/rvm/{gems,rubies,wrappers,environments,log,bin}/${rubyname}
