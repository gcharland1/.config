#!/bin/bash

cd /home/devjava/git/Omnimed-solutions

SOLUTION=${1:-"omnimed-api-access-identity"}


DEPENDENCY_LIST+=($(cat $SOLUTION/solutionDependencies.txt | tr '\n' ' '))

previousLength=0
newLength=${#DEPENDENCY_LIST[@]}
while [[ $previousLength -ne $newLength ]]; do
    previousLength=$newLength
    for dependency in ${DEPENDENCY_LIST[@]}; do
        for new_dependency in $(cat $dependency/solutionDependencies.txt | tr '\n' ' '); do
            if ! [[ " ${DEPENDENCY_LIST[@]} " =~ " $new_dependency " ]]; then
                DEPENDENCY_LIST+=($new_dependency) 
            fi
        done
    done
    DEPENDENCY_LIST=($(printf "%s\n" "${DEPENDENCY_LIST[@]}" | sort -u))
    newLength=${#DEPENDENCY_LIST[@]}
done

echo "Depenencies are ${DEPENDENCY_LIST[*]}"

hashSentence=$(git --no-pager rev-parse HEAD:$SOLUTION)
echo "Commit hashes:"
echo -e "\t- $SOLUTION : $hashSentence"

for sol in "${DEPENDENCY_LIST[@]}"; do
    solHash=$(git --no-pager rev-parse HEAD:$sol)
    hashSentence=$hashSentence$solHash
    echo -e "\t- $sol : $solHash"
done

hash=$(echo $hashSentence | sha1sum | head -c 11)

echo "Hash sentence was: $hashSentence"
echo "Unique id is: $hash"
