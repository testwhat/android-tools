#!/bin/bash
prog="$0"
BASE_PATH=$(realpath $(dirname "$prog"))
PATH_CONFIG=$BASE_PATH/local.properties

[ -f $PATH_CONFIG ] && while IFS='=' read -r k v; do
   export "$k"="$v"
done < $PATH_CONFIG

if [ -z $TOOLS_DIR ]; then
    echo "TOOLS_DIR (path to tools of android-sdk) does not set in $PATH_CONFIG"
    echo Using $BASE_PATH as tools directory
    TOOLS_DIR=$BASE_PATH
fi

if [[ "$OSTYPE" = "cygwin" || "$OSTYPE" = "msys" ]]; then
    DPS=';'
    OS=windows
    TOOLS_DIR=$(cygpath -w "$TOOLS_DIR")
    BASE_PATH=$(cygpath -w "$BASE_PATH")
else
    DPS=':'
    OS=linux
fi
[ -z $WORK_DIR ] && WORK_DIR=$TOOLS_DIR/..
[ -z $JAVA_EXE ] && JAVA_EXE=java
[ -z $JAVAW_EXE ] && JAVAW_EXE=javaw
[ -z $WITH_CONSOLE ] && WITH_CONSOLE=1

JAR_PATH=$BASE_PATH/lib/sdkmanager.jar$DPS$BASE_PATH/lib/swtmenubar.jar
ARCH=$("$JAVA_EXE" -jar "$BASE_PATH/lib/archquery.jar")
SWT_PATH=$BASE_PATH/lib/$OS/$ARCH

[ $WITH_CONSOLE = 0 ] && JAVA_CMD="$JAVAW_EXE" || JAVA_CMD="$JAVA_EXE"

"$JAVA_CMD" \
    -Dcom.android.sdkmanager.toolsdir="$TOOLS_DIR" \
    -Dcom.android.sdkmanager.workdir="$WORK_DIR" \
    -classpath "$JAR_PATH$DPS$SWT_PATH/swt.jar" com.android.sdkmanager.Main "$@"

