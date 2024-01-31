#!/bin/bash

CWD=$PWD
if [ "$1" != "" ] && [ "$2" != "" ]; then
    SERVICE="$2"
    TYPE="$1"
else
    echo "Need to call type AND solution\n    -> startK8sPod api prescribeit"
    exit
fi

WD="$HOME/git/Omnimed-solutions/omnimed-$TYPE-$SERVICE"
if [ "$WD" != "" ]; then
    cd $WD
fi

if [ "$TYPE" == "api" ] || [ "$TYPE" == "config" ] || [ "$TYPE" == "integration" ]; then
    echo "Building and deploying solution $TYPE-$SERVICE"
    echo "Output log available at ~/Documents/stacks/k8s/$TYPE-$SERVICE.log"
    { mvn package -q -Dmaven.test.skip=true && skaffold run; } > ~/Documents/stacks/$TYPE-$SERVICE.log & disown;
elif [ "$TYPE" == "frontend" ]; then
    echo "Building and deploying solution $TYPE-$SERVICE"
    echo "Output log available at ~/Documents/stacks/k8s/$TYPE-$SERVICE.log"
    if [ -f "gulpfile.js" ]; then
        CMD="gulp build"
    else
        CMD="npm run pre-deploy"
    fi
    $($CMD && skaffold run) > ~/Documents/stacks/$TYPE-$SERVICE.log & disown;
fi

cd $CWD
