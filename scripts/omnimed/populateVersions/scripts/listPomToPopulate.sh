#!/bin/bash
 
BASE_DIR="$HOME/git/Omnimed-solutions/"

cd $BASE_DIR
SOLUTION_LIST=$1
[ -z "$SOLUTION_LIST" ] && SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' -not -path '*omnimed-cuba*' -not -path '*omnimed-cumulus*' -not -path '*omnimed-saltstack*' -not -path '*.iml' | sort | cut -d/ -f2)
SOLUTION_COUNT=$(echo ${SOLUTION_LIST[@]} | wc -w)

getSolutionsDependingOnMe() {
    local parent=$1

    declare childrenList=$(grep -lE $parent omnimed-*/solutionDependencies.txt | cut -d/ -f1 | sort | uniq)
    [ -z "$childrenList" ] && return

    local pathToChildren=$(echo "$childrenList" | sed -e "s/\(omnimed-.*\)/-or -path '*\/\1\/*'/g")

#    # TODO ajouter un filtre qui fait qu'on cherche uniquement dans les solutions modifiés
    local startTime=$(date +%s%3N)
    if [[ $parent =~ "-parent" ]]; then
        local sedCmd="/<artifactId>$parent<\/artifactId>/,/<\/parent>/s/<version>0\.0\.0<\/version>/<version>$parentVersion<\/version>/g"
        echo $(find $BASE_DIR -maxdepth 3 -type f \
            -not -path "*/$parent/pom.xml" \
            -not -path "*/target/*" \
            -not -path "*/deploy/*" \
            -not -path "*/node_modules/*" \
            -not -path "*/dist/*" \
            $pathToChildren \
            -name 'pom.xml' \
            -exec grep -lE -m 1 "<artifactId>$parent</artifactId>" {} \;)
    else
        local sedCmd="s/<$parent\.version>0\.0\.0<\/$parent\.version>/<$parent\.version>$parentVersion<\/$parent\.version>/g" 
        echo $(find $BASE_DIR -maxdepth 3 -type f \
           -not -path "*/$parent/pom.xml" \
            -not -path "*/target/*" \
            -not -path "*/deploy/*" \
            -not -path "*/node_modules/*" \
            -not -path "*/dist/*" \
            -name 'pom.xml' \
            -exec grep -lE -m 1 "<$parent\.version>" {} \;)
    fi
    echo "Populate for children: $(expr $(date +%s%3N) - $startTime)"
}

for s in ${SOLUTION_LIST[@]}; do
    getSolutionsDependingOnMe $s
done
