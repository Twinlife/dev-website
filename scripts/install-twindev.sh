#!/bin/sh
cd /opt
if test -f $1; then
  tar xf $1
  name=`basename $1 .tar.gz`
  if test -d $name; then
      chown -R twindev:twindev $name
      service twindev stop
      rm /opt/twindev
      ln -s /opt/$name twindev
      service twindev start
  else
      echo "Installation of $1 failed"
      exit 1
  fi
else
    echo "Archive file $1 not found"
    exit 2
fi
