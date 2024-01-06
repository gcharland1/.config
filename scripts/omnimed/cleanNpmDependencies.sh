#!/usr/bin/bash

SOL_LIST=$(ls ~/git/Omnimed-solutions | grep omnimed-frontend-)

IFS=$'\n' read -r -d '' -a SOL_LIST < <( ls ~/git/Omnimed-solutions/ | grep omnimed-frontend && printf '\0' )

#for DIR in "omnimed-frontend-prescribeit"; do
for DIR in "${SOL_LIST[@]}"; do
    cd $HOME/git/Omnimed-solutions/$DIR
    depcheck > unused_dependencies.txt || true

    echo "$DIR:"
    echo "  - Total of $(wc -l unused_dependencies.txt)"
    sed -i '0,/^Unused dependencies/d' unused_dependencies.txt
    sed -i '/^Unused devDependencies$/,$d' unused_dependencies.txt
    sed -i 's/.*\* //' unused_dependencies.txt 
    IFS=$'\n' read -r -d '' -a DEP_LIST < <( cat unused_dependencies.txt )

    echo "  - Will remove $(wc -l unused_dependencies.txt)"
    echo "---------------------"
    for DEP in "${DEP_LIST[@]}"; do
        sed -i "/.*${DEP}.*/d" package.json
    done
done
echo "Done. See git diff for details"
