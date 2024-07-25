#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/"

cd $BASE_DIR
#SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
#SOLUTION_LIST=$(find ./ -maxdepth 3 -type f -path '*omnimed-*' -name 'pom.xml' | sed -e 's:.*\(omnimed-.*\)/pom.xml:\1:g')
SOLUTION_LIST=$(find $M2_DIR"omnimed" -type d -name 'omnimed-*')

for s in ${SOLUTION_LIST[@]}; do
    find $s -type d -not -name "omnimed-*" -not -name "0.0.0" -exec rm -r {} \;
done

cd $BASE_DIR
