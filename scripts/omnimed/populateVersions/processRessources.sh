#!/bin/bash
 
OMNIMED_SOLUTIONS=$HOME/git/Omnimed-solutions
BASE_DIR=$HOME/.config/scripts/omnimed/populateVersions/
#BASE_DIR=$HOME/git/Omnimed-solutions/build-tools/workspace/local

cd $OMNIMED_SOLUTIONS

SOLUTION_LIST=$1
[ -z "$SOLUTION_LIST" ] \
    && SOLUTION_LIST=$(find ./ -maxdepth 2 -type f -path '*omnimed-*/pom.xml' \
        -not -path '*omnimed-cuba*' \
		-not -path '*omnimed-cumulus*' \
		-not -path '*omnimed-saltstack*' \
		-not -path '*.iml' \
        | sort \
        | cut -d/ -f2)

HAS_STASHED_CHANGES=0
stashId="PROCESS_RESSOURCES_$(date "+%Y-%m-%d %H:%M:%S")"
#if [[ ! -z "$(git status --short)" ]]; then
#    echo -e "Stashing local changes with stash id\n\t $stashId\n"
#    HAS_STASHED_CHANGES=1
#    git stash push -m "$stashId"
#fi

echo "###### Process Ressources ######"
$BASE_DIR/scripts/version.sh "$SOLUTION_LIST"
$BASE_DIR/scripts/rebuild.sh "$SOLUTION_LIST"
#$BASE_DIR/cleanup.sh

if [ $HAS_STASHED_CHANGES == 1 ]; then
    echo "Restoring stashed local files"
    git stash pop stash@{0}
    git status --short | sed 's/^/\t| /g'
fi
