#!/bin/sh

mydir="`dirname $0`"
case `uname -s` in
    MINGW*|CYGWIN*)
      mydir=`cygpath -m $mydir`
      ;;
esac

eval "java" "-Xbootclasspath/p:${mydir}/javac.jar" com.sun.tools.javac.Main "$@"
