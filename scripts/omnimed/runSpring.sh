#!/bin/bash

# Get current api name from path
IFS='/' read -ra PATH_ARRAY <<< "$PWD"
FULL_API_NAME="${PATH_ARRAY[-1]}"

IFS='-' read -ra API_NAME_ARRAY <<< "$FULL_API_NAME"
API_NAME="${API_NAME_ARRAY[-1]}"

mkdir -p .temp
CLASSPATH_FILE=".temp/$FULL_API_NAME.classpath"
SELF_JAR="$HOME/git/Omnimed-solutions/$FULL_API_NAME/target/$FULL_API_NAME-0.0.0.jar:"

mvn dependency:build-classpath -Dmdep.outputFile=$CLASSPATH_FILE
echo "$SELF_JAR$(cat $CLASSPATH_FILE)" > $CLASSPATH_FILE
CLASS_PATH=$(cat $CLASSPATH_FILE)

IFS='.' read -ra CLASS_FILE <<< "$(ls src/main/java/com/omnimed/api/$API_NAME/ | grep java)"
CLASS_NAME="${CLASS_FILE[0]}"
MAIN_CLASS="com.omnimed.api.$API_NAME.$CLASS_NAME"

RUN_CMD="/usr/lib/jvm/jdk-11.0.3/bin/java -XX:TieredStopAtLevel=1 -noverify -Dspring.profiles.active=dev -Dspring.output.ansi.enabled=always -Dcom.sun.management.jmxremote -Dspring.jmx.enabled=true -Dspring.liveBeansView.mbeanDomain -Dspring.application.admin.enabled=true -Dfile.encoding=UTF-8 -classpath ${CLASS_PATH} $MAIN_CLASS"
$RUN_CMD
rm -r .temp
