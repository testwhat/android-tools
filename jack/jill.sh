#!/bin/sh

mydir="`dirname $0`"
case `uname -s` in
    CYGWIN*)
      mydir=`cygpath -m $mydir`
      ;;
esac

eval "java" "-Xmx1024m" "-cp" "${mydir}"/jack.jar "com.android.jill.Main" "$@"
