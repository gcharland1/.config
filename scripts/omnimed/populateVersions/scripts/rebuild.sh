#!/bin/bash

BASE_DIR="$HOME/git/Omnimed-solutions/"
M2_DIR="$HOME/.m2/repository/com/omnimed/"
OUTPUT_FILE="processRessource.log"
VIRGO_PATH="/home/devjava/Applications/virgo-tomcat-server-3.6.3-Engine.RELEASE"
VIRGO_DIR="$VIRGO_PATH/repository"


cd $BASE_DIR
SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
SOLUTION_COUNT=$(echo ${SOLUTION_LIST[@]} | wc -w)

updateProgess() {
    echo -e "\e[1A\e[K$1"
}

removeCachedErrors() {
    local cachedError="$1"

    local endString=" was not found in https:"
    local sol=""
    local startString="The following artifacts could not be resolved: "
    local ver=""

    local artifactsList=$(echo "$cachedError" | sed -e "s/.*$startString\(.*\)$endString.*/\1/g" | tr ',' '\n' | sort | uniq)
    declare -a solutionsToRebuild
    for d in ${artifactsList[@]}; do
        sol=$(getSolutionNameFromCacheStack $d)
        ver=$(getSolutionVersionFromCacheStack $d)
        echo "Removing $(find $M2_DIR -type d -path "*/$sol/*" -name "$ver") before rebuilding $sol"
        find $M2_DIR -type d -path "*/$sol/*" -name "$ver" -exec rm -r {} \;
        mavenCleanInstall $sol
    done
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

    cd $BASE_DIR$sol &> /dev/null
    declare mvnArguments=$(getMavenArgumentsList $sol)

    updateProgess "\t${#checkedSolutionList[@]} / $SOLUTION_COUNT (${#alreadyCompiledSolutionList[@]} pre-existing, ${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - $sol"
    mvn clean install $mvnArguments &> $BASE_DIR$sol/$OUTPUT_FILE \
        && rebuiltSolutionList+=( "$sol/" ) \
        || failedSolutionList+=( "$sol/" )
}

rebuildSolution() {
    local sol=$1

    [[ ${checkedSolutionList[*]} =~ "$1/" ]] && return

    updateProgess "\t${#checkedSolutionList[@]} / $SOLUTION_COUNT (${#alreadyCompiledSolutionList[@]} pre-existing, ${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - $sol"

    declare -a solutionDependencies
    [ -f $BASE_DIR$sol/solutionDependencies.txt ] && solutionDependencies=$(cat $BASE_DIR$sol/solutionDependencies.txt | tr "\n" " ")
    for dep in ${solutionDependencies[@]}; do
        rebuildSolution $dep
    done
    
    local version=$(cat $BASE_DIR$sol/solutionVersion.txt)

    local compiledSource=$(find $M2_DIR -type d -path "*/$sol/*" -name $version)
    [ -z "$compiledSource" ] && mavenCleanInstall $sol || alreadyCompiledSolutionList+=( "$sol/" )

    checkedSolutionList+=( "$sol/" )
}

getSolutionNameFromCacheStack() {
    local mavenName="$1"

    mavenName=$(echo "$mavenName" | sed -e 's/.*:\(.*\):jar.*/\1/')
    echo $mavenName
}

getSolutionVersionFromCacheStack() {
    local version="$1"

    version=$(echo "$version" | sed -e 's/.*jar\:\(.*\)/\1/g;s/\(.*\):$/\1/g')
    echo $version
}


echo "-------------------------------"
echo "Rebuilding the solutions in order"
echo "..."
declare -a failedSolutionList
declare -a rebuiltSolutionList
declare -a checkedSolutionList
declare -a alreadyCompiledSolutionList
for s in ${SOLUTION_LIST[@]}; do
    rebuildSolution $s
done
updateProgess "\t${#checkedSolutionList[@]} / $SOLUTION_COUNT (${#alreadyCompiledSolutionList[@]} pre-existing, ${#rebuiltSolutionList[@]} rebuilt, ${#failedSolutionList[@]} failed) - $sol"

echo -e "\nFailed compilations:"
for s in ${failedSolutionList[@]}; do
    echo -e "\t $s"
done

echo -e "\n-------------------------------"
echo "Trying to fix the failed solutions..."
declare cacheMessage="This failure was cached in the local repository and resolution" 
for s in ${failedSolutionList[@]}; do
    cachedError=$(grep -m 1 "$cacheMessage" $BASE_DIR$s/$OUTPUT_FILE)
    if [ ! -z "$cachedError" ]; then
        removeCachedErrors $cachedError
        mavenCleanInstall $s
    else
        echo "### $s failed because of"
        head -4 $BASE_DIR$s/$OUTPUT_FILE | sed 's/^/\t\|/g'
        echo -e "\n"
    fi
done

cd $BASE_DIR
