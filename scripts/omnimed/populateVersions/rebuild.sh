#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')


updateProgess() {
    echo -e "\e[1A\e[K$1"
}

mavenCleanInstall() {
    local sol=$1

    # TO DO :
    # Ajouter la logique de mvn clean install pour virgo (porcessRessources:512)
    updateProgess "\t${#compiledSolutionList[@]} / $SOLUTION_COUNT (${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - Rebuilding $sol"

    cd $BASE_DIR$sol > /dev/null
    mvn clean install -T 1C -P Dev -q -e -fae -Dmaven.test.skip=true > $BASE_DIR$sol/mvi_output.txt \
        && rebuiltSolutionList+=( "$sol" ) \
        || failedSolutionList+=( "$sol" )
}

rebuildSolution() {
    [[ ${compiledSolutionList[*]} =~ "$1" ]] && return

    local sol=$1

    if [ -f "$BASE_DIR$sol/solutionDependencies.txt" ]; then
        local solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
        for dep in ${solDependencies[@]}; do
            rebuildSolution $dep  \
                || echo "Failed to rebuild $dep"; echo "-"
        done
    fi
    
    local version=$(cat $BASE_DIR$sol/solutionVersion.txt)
    local compiledSource=$(find $M2_DIR -maxdepth 5 -type d -path "*/$sol/*" -name $version)
    
    [ ! -z "$compiledSource" ] && mavenCleanInstall $sol
    
    compiledSolutionList+=( "$sol" )
    updateProgess "\t${#compiledSolutionList[@]} / $SOLUTION_COUNT (${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed)" 
}


echo "-------------------------------"
echo "Rebuilding the solutions in order"
echo "..."
declare -a failedSolutionList
declare -a rebuiltSolutionList
declare -a compiledSolutionList
for s in ${SOLUTION_LIST[@]}; do
    rebuildSolution $s
done

echo "Failed compilations:"
for s in ${failedSolutionList[@]}; do
    echo "\t - $s"
done

cd $BASE_DIR
