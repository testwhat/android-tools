#!/bin/sh

mydir="`dirname $0`"
case `uname -s` in
    MINGW*|CYGWIN*)
      mydir=`cygpath -m $mydir`
      ;;
esac

eval "java" "-Xmx1024m" "-jar" "${mydir}"/jack.jar "$@"
