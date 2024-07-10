#!/bin/bash

#mvn clean install -Dmaven.test.skip=true -Dgit.version.number=1a2b3c
 
BASE_DIR="$HOME/git/Omnimed-solutions/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')

populateVersionForDependentSolutions() {
    local parent=$1
    local parentVersion=$2

    local dependencyFile='omnimed-*/solutionDependencies.txt' 
    local parentVersion=${gitHashMap[$parent]}
    
    local children=$(grep -lE $parent $dependencyFile | cut -d/ -f1 | sort | uniq)

    for c in ${children[@]}; do
        local sedCmd="s/<$parent\.version>0\.0\.0<\/$parent\.version>/<$parent\.version>$parentVersion<\/$parent\.version>/g" 
        sed -i $sedCmd $BASE_DIR$c/pom.xml
    done
}

populateVersionForSolution() {
    [[ ${populatedSolutions[*]} =~ "$1" ]] && return

    local sol=$1
    local version=${gitHashMap["$sol"]}
    
    if [ -f "$BASE_DIR$sol/solutionDependencies.txt" ]; then
        local solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
        for dep in ${solDependencies[@]}; do
            populateVersionForSolution $dep
        done
    fi

    populateVersionForDependentSolutions $sol $version

    # Pom.xml
    local sedCmd="s/^\t<version>0\.0\.0<\/version>/\t<version>$version<\/version>/g" 
    find $BASE_DIR$sol -maxdepth 2 -type f -name 'pom.xml' -exec sed $sedCmd -i {} \;

    ## package.json
    #local sedCmd="s/\"0.0.0\"/\"$version\"/" 
    #find $BASE_DIR$sol -type f -name 'package.json' -exec sed $sedCmd -i {} \;
    #
    ## package-lock.json
    #local sedCmd="0,/0\.0\.0/s/\"0\.0\.0\"/\"$version\"/"
    #find $BASE_DIR$sol -type f -name 'package-lock.json' -exec sed $sedCmd -i {} \;
    #
    #
    ## Dockerfile
    #local sedCmd="s/VERSION=0\.0\.0/VERSION=$version/"
    #find $BASE_DIR$sol -type f -name 'Dockerfile' -exec sed $sedCmd -i {} \;

    populatedSolutions+=( "$sol" )
    echo "Populated ${#populatedSolutions[@]} / $SOLUTION_COUNT solutions"
}

# Get git commits for each solution
echo "Getting the git hash for each solution"
cd $BASE_DIR
declare -A gitHashMap
for s in ${SOLUTION_LIST[@]}; do
    gh=$(git --no-pager log -1 --pretty=format:%h -- ./$s)
    gitHashMap[$s]=$gh
done
cd -

declare -a populatedSolutions
for s in ${SOLUTION_LIST[@]}; do
    populateVersionForSolution $s
done

for s in ${SOLUTION_LIST[@]}; do
    [[ ${populatedSolutions[*]} =~ "$s" ]] && break || echo "$s has not been populated"
done

