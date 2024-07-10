#!/bin/bash
 
BASE_DIR="$HOME/git/Omnimed-solutions/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')

updateProgess() {
    echo -e "\e[1A\e[K$1"
}

populateVersionForDependentSolutions() {
    local parent=$1
    local parentVersion=$2

    local dependencyFile='omnimed-*/solutionDependencies.txt' 
    local children=$(grep -lE $parent $dependencyFile | cut -d/ -f1 | sort | uniq)

    if [[ $parent =~ "-parent-" ]]; then
        local sedCmd="/<parent>/,/<\/parent>/s/<version>0\.0\.0<\/version>/<version>$parentVersion<\/version>/g"
    else
        local sedCmd="s/<$parent\.version>0\.0\.0<\/$parent\.version>/<$parent\.version>$parentVersion<\/$parent\.version>/g" 
    fi

    #sedCmd+=";s/<version>\${$parent\.version}<\/version>/<version>0\.0\.0<\/version>/g"
    for c in ${children[@]}; do
        find $BASE_DIR$c -maxdepth 2 -type f -name 'pom.xml' -exec sed $sedCmd -i {} \;
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

    local sedCmd="s/^\t<version>0\.0\.0<\/version>/\t<version>$version<\/version>/g" 
    find $BASE_DIR$sol -maxdepth 2 -type f -name 'pom.xml' -exec sed $sedCmd -i {} \;
    
    echo $version > $BASE_DIR$sol/solutionVersion.txt

    populatedSolutions+=( "$sol" )
    updateProgess "\t${#populatedSolutions[@]} / $SOLUTION_COUNT"
}

cd $BASE_DIR > /dev/null 
echo "# Populate solutions versions #"

echo "-------------------------------"
echo "Getting the git hash for each solution"
echo ""
declare -A gitHashMap
for s in ${SOLUTION_LIST[@]}; do
    gh=$(git --no-pager log -1 --pretty=format:%h -- ./$s)
    gitHashMap[$s]=$gh
    updateProgess "\t${#gitHashMap[@]} / $SOLUTION_COUNT"
done
cd - > /dev/null 
echo "-------------------------------"
echo "Populating the version for each solution"
echo ""
declare -a populatedSolutions
for s in ${SOLUTION_LIST[@]}; do
    populateVersionForSolution $s
done
