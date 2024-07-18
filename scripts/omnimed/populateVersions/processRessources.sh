#!/bin/bash
 
BASE_DIR=$HOME/.config/scripts/omnimed/populateVersions
OMNIMED_SOLUTIONS=$HOME/git/Omnimed-solutions
#BASE_DIR=$HOME/git/Omnimed-solutions/build-tools/workspace/local

cd $OMNIMED_SOLUTIONS

HAS_STASHED_CHANGES=0
if [[ ! -z "$(git status -s)" ]]; then
    echo "Saving local changes before process ressource"
    git status -s | sed 's/^/\t| /g'
    echo ""
    HAS_STASHED_CHANGES=1
    git stash push -m "Prepare process ressource"
fi

echo "###### Process Ressources ######"
$BASE_DIR/scripts/version.sh
$BASE_DIR/scripts/rebuild.sh

echo "Stashing modified version files"
git stash push -m "PROCES RESSOURCE"
echo ""

if [ $HAS_STASHED_CHANGES == 1 ]; then
    echo "Restoring stashed local files"
    $(git stash pop stash@{1})
    git status -s | sed 's/^/\t| /g'
fi
