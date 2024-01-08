#!/usr/bin/bash

SOL_LIST=$(ls ~/git/Omnimed-solutions | grep omnimed-frontend-)

IFS=$'\n' read -r -d '' -a SOL_LIST < <( ls ~/git/Omnimed-solutions/ | grep omnimed-frontend && printf '\0' )

#for DIR in "omnimed-frontend-angularjs"; do
for DIR in "${SOL_LIST[@]}"; do
    cd $HOME/git/Omnimed-solutions/$DIR
    echo $DIR
    unused=$(depcheck --oneline --ignores="omnimed-*, diacritics, \@angular*" || true)
    unused=$(echo $unused | sed 's/Unused devDependencies.*//' )
    unused=$(echo $unused | sed 's/^Unused dependencies//')

    IFS=' ' read -r -d '' -a DEP_LIST < <(echo $unused)
    for DEP in "${DEP_LIST[@]}"; do
        rgxp=$(echo $DEP | sed 's/\//\\\//g')
        rgxp=$(echo $rgxp | sed 's/\ //g')
        rgxp=$(echo $rgxp | sed 's/-/\\\-/g')
        rgxp="/${rgxp}/d"
        echo $rgxp
        sed -i $rgxp package.json
        # TODO S'assurer de retirer les trailing "," si
        #sed =i 's/\(.*\),\n\(.*}\)/\1\n\2/' package.json
    done
    #npm run unicukes-dev-all
done
echo "Done. See git diff for details"
