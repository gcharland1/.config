#!/bin/bash
 
BASE_DIR="$HOME/git/Omnimed-solutions/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')

updateProgess() {
    #echo -e "$1"
    echo -e "\e[1A\e[K$1"
}

getVersionForSolution() {
    local sol=$1

    [ -f "$BASE_DIR$sol/solutionVersion.txt" ] && version=$(cat $BASE_DIR$sol/solutionVersion.txt)
    [[ "$version" =~ "-SNAPSHOT" && ! -z ${gitHashMap["$sol"]} ]] && version=${gitHashMap["$sol"]}

    [ -z "$version" ] && version="0.0.0"

    echo $version
}

populateVersionForDependentSolutions() {
    local parent=$1
    local parentVersion=$2

    declare childrenList=$(grep -lE $parent omnimed-*/solutionDependencies.txt | cut -d/ -f1 | sort | uniq)
    [ -z "$childrenList" ] && return

    if [[ $parent =~ "-parent" ]]; then
        local sedCmd="/<artifactId>$parent<\/artifactId>/,/<\/parent>/s/<version>0\.0\.0<\/version>/<version>$parentVersion<\/version>/g"
        find $BASE_DIR -maxdepth 3 -type f -not -path "*/$parent/pom.xml" -name 'pom.xml' -exec grep -lE "<artifactId>$parent</artifactId>" {} \; | xargs -I {} sed -i $sedCmd {}
    else
        local sedCmd="s/<$parent\.version>0\.0\.0<\/$parent\.version>/<$parent\.version>$parentVersion<\/$parent\.version>/g" 
        find $BASE_DIR -maxdepth 3 -type f -not -path "*/$parent/pom.xml" -name 'pom.xml' -exec grep -lE "<$parent\.version>" {} \; | xargs -I {} sed -i $sedCmd {}
    fi
}

populateVersionForSolution() {
    local sol=$1

    updateProgess "\t${#populatedSolutions[@]} / $SOLUTION_COUNT - $sol"
    [[ ${populatedSolutions[*]} =~ "$sol" ]] && return

    declare -a solutionDependencies
    [ -f $BASE_DIR$sol/solutionDependencies.txt ] && solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
    for dep in ${solutionDependencies[@]}; do
        populateVersionForSolution $dep
    done

    local version=$(getVersionForSolution $sol)

    populateVersionForDependentSolutions $sol $version

    local sedCmd="s/<version>0\.0\.0<\/version>/<version>$version<\/version>/g" 
    find $BASE_DIR$sol -maxdepth 2 -type f -name 'pom.xml' -exec sed -i $sedCmd {} \;
    
    echo $version > $BASE_DIR$sol/solutionVersion.txt

    populatedSolutions+=( "$sol" )
}

cd $BASE_DIR > /dev/null 
git reset --hard HEAD

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
echo "-------------------------------"
echo "Populating the version for each solution"
echo ""
declare -a populatedSolutions
for s in ${SOLUTION_LIST[@]}; do
    populateVersionForSolution $s
    updateProgess "\t${#populatedSolutions[@]} / $SOLUTION_COUNT - $sol"
done

cd - > /dev/null 
