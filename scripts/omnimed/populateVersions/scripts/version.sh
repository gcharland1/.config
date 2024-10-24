#!/bin/bash
 
BASE_DIR="$HOME/git/Omnimed-solutions/"

cd $BASE_DIR
SOLUTION_LIST=$1
[ -z "$SOLUTION_LIST" ] && SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
SOLUTION_COUNT=$(echo ${SOLUTION_LIST[@]} | wc -w)

updateProgess() {
   #echo -e "\e[1A\e[K$1"
   echo -e "$1"
}

getVersionForSolution() {
    local sol=$1

    [ -f "./$sol/solutionVersion.txt" ] && version=$(cat ./$sol/solutionVersion.txt)
    if [[ "$version" =~ "-SNAPSHOT" ]]; then
        gh=$(git --no-pager log -1 --pretty=format:%h -- ./$s)
        version=$(echo $version | sed "s/SNAPSHOT/$gh-SNAPSHOT/")
    fi

    [ -z "$version" ] && version="0.0.0"

    echo $version
}

populateVersionForDependentSolutions() {
    local parent=$1
    local parentVersion=$2

    declare childrenList=$(grep -lE $parent omnimed-*/solutionDependencies.txt | cut -d/ -f1 | sort | uniq | tr '\n' ' ')
    [ -z "$childrenList" ] && return

    local pathToChildren=$(echo "$childrenList" | sed -e "s/^/-path /;s/\(omnimed-[^ ]*\)/'.\/\1\/*' -o -path/g;s/-o -path $//")

    # TODO ajouter un filtre qui fait qu'on cherche uniquement dans les solutions modifiés
    #local startTime=$(date +%s%3N)
    if [[ $parent =~ "-parent" ]]; then
        local sedCmd="/<parent>/,/<\/parent>/s/<version>0\.0\.0<\/version>/<version>$parentVersion<\/version>/g"
        find ./ -maxdepth 3 -type f \
            ! -path "./$parent/pom.xml" \
            ! -path "*/target/*" \
            ! -path "*/deploy/*" \
            ! -path "*/node_modules/*" \
            ! -path "*/dist/*" \
            -name 'pom.xml' \
            -exec grep -lE -m 1 "<artifactId>$parent</artifactId>" {} \; \
            | xargs -I {} sed -i $sedCmd {}
            #\( $pathToChildren \) \
    else
        local sedCmd="s/<$parent\.version>0\.0\.0<\/$parent\.version>/<$parent\.version>$parentVersion<\/$parent\.version>/g" 
        find ./ -maxdepth 3 -type f \
            -not -path "*/$parent/pom.xml" \
            -not -path "*/target/*" \
            -not -path "*/deploy/*" \
            -not -path "*/node_modules/*" \
            -not -path "*/dist/*" \
            $pathToChildren \
            -name 'pom.xml' \
            -exec grep -lE -m 1 "<$parent\.version>" {} \; \
            | xargs -I {} sed -i $sedCmd {}
    fi
    #echo "Populate for children: $(expr $(date +%s%3N) - $startTime)"
}

populateVersionForSolution() {
    local sol=$1

    [[ ${populatedSolutions[*]} =~ "$sol/" ]] && return

    declare -a solutionDependencies
    [ -f ./$sol/solutionDependencies.txt ] && solutionDependencies=$(cat ./$sol/solutionDependencies.txt | tr "\n" " ")
    for dep in ${solutionDependencies[@]}; do
        populateVersionForSolution $dep
    done

    local version=$(getVersionForSolution $sol)

    populateVersionForDependentSolutions $sol $version &&

    local sedCmd="s/<version>0\.0\.0<\/version>/<version>$version<\/version>/g" 
    find ./$sol -maxdepth 2 -type f \
        -not -path "*/target/*" \
        -not -path "*/deploy/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/dist/*" \
        -name 'pom.xml' -exec sed -i "$sedCmd" {} \;
    #echo "Pom for $sol: $(expr $(date +%s%3N) - $startTime)"
    
    #local startTime=$(date +%s%3N)
    local sedCmd="s/\"version\": \"0.0.0\",/\"version\": \"$version\",/g"
    find ./$sol -maxdepth 1 -type f \
        -not -path "*/target/*" \
        -not -path "*/deploy/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/dist/*" \
        -name 'package.json' -exec sed -i "$sedCmd" {} \;
    #echo "Pom for $sol: $(expr $(date +%s%3N) - $startTime)"

    echo -n $version > ./$sol/solutionVersion.txt

    populatedSolutions+=( "$sol/" )
    updateProgess "\t${#populatedSolutions[@]} / $SOLUTION_COUNT - $sol"
}

echo "Populating the version for each solution"
echo ""
cd $BASE_DIR
declare -a populatedSolutions
for s in ${SOLUTION_LIST[@]}; do
    populateVersionForSolution $s
done
updateProgess "\t${#populatedSolutions[@]} / $SOLUTION_COUNT - Done!"
