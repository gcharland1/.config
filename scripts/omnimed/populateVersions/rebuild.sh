#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"

cd $BASE_DIR
SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
SOLUTION_COUNT=$(echo ${SOLUTION_LIST[@]} | wc -w)

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
    local forceUpdate=$2

    cd $BASE_DIR$sol > /dev/null
    declare mvnArguments=$(getMavenArgumentsList $sol)
    [ $forceUpdate == 1 ] && mvnArguments="$mvnArguments -U"

    echo "$mvnArguments"
    echo -e "\n"
    updateProgess "\t${#compiledSolutionList[@]} / $SOLUTION_COUNT (${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - Working on $sol"
    mvn clean install $mvnArguments > $BASE_DIR$sol/mvi_output.txt \
        && rebuiltSolutionList+=( "$sol" ) \
        || failedSolutionList+=( "$sol" )
}

rebuildSolution() {
    local sol=$1
    declare -i forceUpdate=0
    [[ ! -z "$2" && "$2" == "forceUpdate" ]] && forceUpdate=1

    [[ ${compiledSolutionList[*]} =~ "$1" ]] && return

    updateProgess "\t${#compiledSolutionList[@]} / $SOLUTION_COUNT (${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - Working on $sol"

    declare -a solutionDependencies
    [ -f $BASE_DIR$sol/solutionDependencies.txt ] && solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
    for dep in ${solutionDependencies[@]}; do
        rebuildSolution $dep $forceUpdate
    done
    
    local version=$(cat $BASE_DIR$sol/solutionVersion.txt)

    local compiledSource=$(find $M2_DIR -type d -path "*/$sol/*" -name $version)
    [ -z "$compiledSource" ] && mavenCleanInstall $sol $forceUpdate || compiledSolutionList+=( "$sol" )
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
    echo -e "\t - $s"
done

SOLUTION_COUNT=$(echo ${failedSolutionList[@]} | wc -w)
for s in ${failedSolutionList[@]}; do
    rebuildSolution $s "forceUpdate"
done


cd $BASE_DIR
