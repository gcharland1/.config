#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"
SOLUTION_COUNT=$(ls $BASE_DIR | grep 'omnimed-' | wc -l)
SOLUTION_LIST=$(ls $BASE_DIR | grep 'omnimed-')

VIRGO_PATH="/home/devjava/Applications/virgo-tomcat-server-3.6.3-Engine.RELEASE"
VIRGO_DIR="$VIRGO_PATH/repository"


updateProgess() {
    echo -e "\e[1A\e[K$1"
}


getMavenArgumentsList() {
    local solution=$1
    local goal=$2

    declare mvnArguments
    [[ $solution =~ "^omnimed-(common|engine|healthrecord|interfaces|mock|shared|utils)$" ]] \
        && echo "-P Virgo -q -e -fae -Dmaven.test.skip=true -Ddependencies.repository=$VIRGO_DIR -Dvirgo.profile.phase=install" \
        || echo "-T 1C -P Dev -q -e -fae -Dmaven.test.skip=true"
}

mavenCleanInstall() {
    local sol=$1

    cd $BASE_DIR$sol > /dev/null
    declare mvnArguments=$(getMavenArgumentsList $sol)

    updateProgess "\t${#compiledSolutionList[@]} / $SOLUTION_COUNT (${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - mvn clean install $mvnArguments"
    mvn clean install $mvnArguments > $BASE_DIR$sol/mvi_output.txt \
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
