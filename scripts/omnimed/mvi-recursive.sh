#!/bin/bash

compileSolutionList() {
    while [[ "$#" -gt 0 ]]; do # Loop while there are arguments left
        local dp=$1

        if [[ ! " ${RESOLVED_DEPENDENCIES[*]} " =~ " ${dp} " ]]; then
            # Compiling solution because it has not yet been resolved
            echo "#### Compilation de $dp en cours..."

            cd /home/devjava/git/Omnimed-solutions/$dp
            mvn clean install -Dmaven.test.skip=true -q -U

            if [ $? -eq 0 ]; then
                RESOLVED_DEPENDENCIES+=($dp)
            else
                echo "###### Compilation en erreur pour $dp. Tentative de recompilation en incluant ses dépendances"

                compileDependencies $dp
                echo "###### Toutes les dépendances $dp ont été compilées. Tentative de recompilation en cours..."
                mvn clean install -Dmaven.test.skip=true -q -U
                if [ $? -eq 0 ]; then
                    echo "##### !!!! Problème de compilation avec $dp. Régler manuellement"
                else
                    RESOLVED_DEPENDENCIES+=($dp)
                fi
            fi
        fi
        shift # Shift to the next argument
    done
}

compileDependencies() {
    if [ -z $1 ]; then
        local sol=$(pwd | rev | cut -d/ -f1 | rev)
    else
        local sol=$1
    fi

    cd /home/devjava/git/Omnimed-solutions/$sol

    compileSolutionList $(cat solutionDependencies.txt)
}

if [ -z $1 ]; then
    sol=$(pwd | rev | cut -d/ -f1 | rev)
else
    sol=$1
fi

RESOLVED_DEPENDENCIES=()

compileDependencies $sol

echo "## Toutes les dépendances ont été compilées. Compilation de $sol en cours..."
mvn clean install -Dmaven.test.skip=true -q -U
