#!/bin/sh
CDIR=/etc/twindev
DDIR=/opt/data
DIR=/opt/twindev
cd /opt
if test -f $1; then
  tar xf $1
  name=`basename $1 .tar.gz`
  if test -d $name; then
      chown -R twindev:twindev $name
      service twindev stop
      rm /opt/twindev /opt/twindev/images/about
      ln -s /opt/$name twindev
      ln -s $DDIR/storage /opt/$name/storage
      ln -s $DDIR/upload /opt/$name/upload
      ln -s $DDIR/preview /opt/$name/web/preview
      ln -s $DDIR/about /opt/$name/web/images/about
      service twindev start
  else
      echo "Installation of $1 failed"
      exit 1
  fi
else
    echo "Archive file $1 not found"
    exit 2
fi
