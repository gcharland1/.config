#!/bin/bash

DEPLOY_SOLUTION="$HOME/Documents/myScripts/startK8sPod.sh"

API_LIST=(
    "transmission"
    "prescribeit" 
    "medication"
    "engine"
)
FRONTEND_LIST=(
    "transmission"
    "prescribeit"
    "communication"
    "medication"
)

MAX_JOB_COUNT=3
i=0
n=0

while (( $i < ${#API_LIST[@]} )); do
    if (( $n < $MAX_JOB_COUNT )); then
        n=$((n+1)); $DEPLOY_SOLUTION "api" "${API_LIST[$i]}"; n=$((n-1)) &
        i=$((i+1))
    fi
done

while (( $i < ${#FRONTEND_LIST[@]} )); do
    if (( $n < $MAX_JOB_COUNT )); then
        n=$((n+1)); $DEPLOY_SOLUTION "api" "${API_LIST[$i]}"; n=$((n-1)) &
        i=$((i+1))
    fi
done
