#!/bin/bash

BROWSER="google-chrome"

declare -a options=(
    "Google - https://www.google.com/search?q="
    "Amazon - https://www.amazon.ca/s?k="
    "GitHub - https://github.com/search?q="
    "Youtube - https://www.youtube.com/results?search_query="
)

selectedEngine=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Select search engine:' -l 20)

[ -z "$selectedEngine" ] && exit
url=$(echo "$selectedEngine" | awk '{print $NF}'); engine=$(echo "$selectedEngine" | awk '{print $1}')

query=$(dmenu -i -p "Seaching $engine:" -l 20)
[ -z "$query" ] && exit

query=$(echo $query | tr ' ' '+')
$BROWSER "$url$query"
