#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"

cd $BASE_DIR
SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)

for s in ${SOLUTION_LIST[@]}; do
    currentVersion=$(cat $BASE_DIR$s/solutionVersion.txt)
    versions=$(find $M2_DIR -type d -path "*/$s/*" -not -name "$currentVersion" -not -name "0.0.0" -exec rm -r {} \;)
done

cd $BASE_DIR
