#!/bin/sh

mydir="`dirname $0`"
case `uname -s` in
    MINGW*|CYGWIN*)
      mydir=`cygpath -m $mydir`
      ;;
esac

eval "java" "-jar" "${mydir}"/d8.jar "$@"
