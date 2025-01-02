#!/bin/bash

selectedProcess=$(ps -aux | dmenu -i -p 'Select process:' -b -l 20)
[ ! -z "$selectedProcess" ] \
    && pid=$(echo $selectedProcess | awk '{print $2}') \
    || exit

declare -a opts=("Yes" "No")
[ ! -z "$pid" ] \
    && confirm=$(printf '%s\n' "${opts[@]}" | dmenu -i -p "Confirm kill process $pid?" -b ) \
    || exit

[ "$confirm" == "Yes" ] \
    && kill -9 $pid
