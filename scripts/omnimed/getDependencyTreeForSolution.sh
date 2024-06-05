#!/bin/bash

CWD=$PWD
if [ "$1" != "" ]; then
    SERVICE="$1"
fi

cd ~/git/Omnimed-solutions

SOLUTION_DEPENDENCIES=$(cat $SERVICE/solutionDependencies.txt);

PARENT_DEPENDENCIES=""
for d in $SOLUTION_DEPENDENCIES; do
    if [ -f "$d/solutionDependencies.txt" ]; then
        for dd in $(cat "$d/solutionDependencies.txt"); do
            if [[ ! ($SOLUTION_DEPENDENCIES =~ $dd  || $PARENT_DEPENDENCIES =~ $dd) ]]; then
                PARENT_DEPENDENCIES+=" $dd";
            fi;
        done;
    fi;
done;

SECOND_LEVEL_PARENTS=""
for d in $PARENT_DEPENDENCIES; do
    if [ -f "$d/solutionDependencies.txt" ]; then
        for dd in $(cat "$d/solutionDependencies.txt"); do
            if [[ ! ($SECOND_LEVEL_PARENTS =~ $dd  || $PARENT_DEPENDENCIES =~ $dd) ]]; then
                SECOND_LEVEL_PARENTS+=" $dd";
            fi;
        done;
    fi;
done;

THIRD_LEVEL_DEPENDENCIES=""
for d in $SECOND_LEVEL_PARENTS; do
    if [ -f "$d/solutionDependencies.txt" ]; then
        for dd in $(cat "$d/solutionDependencies.txt"); do
            if [[ ! ($SECOND_LEVEL_PARENTS =~ $dd  || $THIRD_LEVEL_DEPENDENCIES =~ $dd) ]]; then
                THIRD_LEVEL_DEPENDENCIES+=" $dd";
            fi;
        done;
    fi;
done;

echo "THIRD: $THIRD_LEVEL_DEPENDENCIES"
echo "SECOND: $SECOND_LEVEL_PARENTS"
echo "\tFIRST: $PARENT_DEPENDENCIES"
echo "\t\tSOLUTION: $SOLUTION_DEPENDENCIES"
