#!/usr/bin/bash


SOL_LIST=$(ls ~/git/Omnimed-solutions | grep omnimed-frontend-)

IFS=$'\n' read -r -d '' -a FRONTEND_SOLUTION_LIST < <( ls ~/git/Omnimed-solutions/ | grep omnimed-frontend && printf '\0' )

#for DIR in "${FRONTEND_SOLUTION_LIST[@]}"; do
#    echo cd to $DIR
#    cd $HOME/git/Omnimed-solutions/$DIR
#    depcheck > unused_dependencies.txt || true
#done
#
for DIR in "${FRONTEND_SOLUTION_LIST[@]}"; do
    cd $HOME/git/Omnimed-solutions/$DIR
    cat unused_dependencies.txt
done

