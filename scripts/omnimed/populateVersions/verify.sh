#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')

updateProgess() {
    echo -e "\e[1A\e[K$1"
}

verifySolution() {
    [[ ${verifiedSolutionList[*]} =~ "$1" ]] && return

    local sol=$1

    declare -a solutionDependencies
    [ -f $BASE_DIR$sol/solutionDependencies.txt ] && solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
    for dep in ${solutionDependencies[@]}; do
        verifySolution $dep
    done
    
    # Solution needs to be rebuilt?
    local version=$(cat $BASE_DIR$sol/solutionVersion.txt)
    local compiledSource=$(find $M2_DIR -type d -path "*/$sol/*" -name $version)
    [ ! -z "$compiledSource" ] && modifiedSolutionList+=( "$sol" )

    # Parent solution needs to be rebuilt?
    for p in ${solutionDependencies[@]}; do
        [[ ${modifiedSolutionList[*]} =~ "$p" ]] && parentsAreModified+=( "$sol" ) && break
    done

    verifiedSolutionList+=( "$sol" )
    updateProgess "\t${#verifiedSolutionList[@]} / $SOLUTION_COUNT (${#modifiedSolutionList[@]} modified, ${#parentsAreModified[@]} to rebuild because of their parents)" 
}


cd $BASE_DIR > /dev/null

declare -a modifiedSolutionList
declare -a parentsAreModified
declare -a verifiedSolutionList

echo "-------------------------------" 
echo "Computing solutions to deploy"
echo ""
for s in ${SOLUTION_LIST[@]}; do
    verifySolution $s
done

declare solutionsToRebuild=$(echo "${modifiedSolutionList[*]}${parentsAreModified[*]}" | tr " " "\n" | sort | uniq)
echo -e "${#solutionsToRebuild[@]} solutions to rebuild:\n\t${#modifiedSolutionList[@]} modified\n\t${#parentsAreModified[@]} to rebuild because of their parents"
