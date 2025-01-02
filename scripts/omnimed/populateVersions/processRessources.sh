#!/bin/bash
 
OMNIMED_SOLUTIONS=$HOME/git/Omnimed-solutions
BASE_DIR=$HOME/.config/scripts/omnimed/populateVersions/
#BASE_DIR=$HOME/git/Omnimed-solutions/build-tools/workspace/local

cd $OMNIMED_SOLUTIONS

REBUILD_SOLUTION_LIST=$1
SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' \
    -not -path '*omnimed-cuba*' \
    -not -path '*omnimed-cumulus*' \
    -not -path '*omnimed-saltstack*' \
    -not -path '*.iml' \
    | sort \
    | cut -d/ -f2)

[ -z "$REBUILD_SOLUTION_LIST" ] \
    && REBUILD_SOLUTION_LIST=$SOLUTION_LIST


if [[ ! -z "$(git status --short)" ]]; then
    stashId="PROCESS_RESSOURCES_$(date "+%Y-%m-%d %H:%M:%S")"
    echo -e "Stashing local changes with stash id\n\t $stashId\n"
    git stash push -m "$stashId"
fi

echo "###### Process Ressources ######"
$BASE_DIR/scripts/version.sh "$SOLUTION_LIST"
$BASE_DIR/scripts/rebuild.sh "$REBUILD_SOLUTION_LIST"

git add ./
git commit -m "PROCESS RESSOURCE - $(date "+%Y-%m-%d %H:%M")"

[[ ! -z "$stashId" ]] && git stash pop
