#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/"
SOLUTION_LIST=$1

cd $BASE_DIR
[ -z "$SOLUTION_LIST" ] && SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
SOLUTION_COUNT=$(echo ${SOLUTION_LIST[@]} | wc -w)

updateProgess() {
    echo -e "\e[1A\e[K$1"
}

getVersionForSolution() {
    local sol=$1

    version="0.0.0"
    [ -f "$BASE_DIR$sol/solutionVersion.txt" ] && version=$(cat $BASE_DIR$sol/solutionVersion.txt)

    echo $version
}

cleanupM2Folder() {
    local sol=$1
    local version=$(getVersionForSolution $sol)

    [[ "$version" == "0.0.0" ]] && return
    
    pathToM2=$(echo $sol | tr '-' '/')
    local versionFolder=$(find $M2_DIR$pathToM2 -maxdepth 3 -type d -path "*/$sol/*" -name "$version")
    [ -z "$versionFolder" ] && return

    solutionM2Folder=$(echo $versionFolder | rev | cut -d/ -f 2- | rev)
    for f in $(ls $versionFolder); do
        destination=$(echo $f | sed -e "s/$sol-$version.\(.*\)/$sol-0.0.0.\1/")
        echo $destination
    done
}


for s in ${SOLUTION_LIST[@]}; do
    cleanupM2Folder $s
done
