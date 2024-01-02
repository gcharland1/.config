#!/bin/bash

CWD=$PWD

RESSOURCES=( "apidefinition-" "apiclient-angular-" "apiclient-java-" "apiclient-java-spring3-" "api-" )

if [ "$1" != "" ]; then
    API="$1"
    if [ -d "$HOME/git/Omnimed-solutions/omnimed-api-$API" ]; then
        for DIR in "${RESSOURCES[@]}"; do
            if [ -d "$HOME/git/Omnimed-solutions/omnimed-$DIR$API" ]; then
                cd $HOME/git/Omnimed-solutions/omnimed-$DIR$API
                mvn clean install -Dmaven.test.skip=true
            fi
        done
    else
        echo "omnimed-api-$API doesn't exist. Enter a valid api name."
    fi
else
    echo "API name required as argument."
fi

cd $CWD
