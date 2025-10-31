#!/bin/sh
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {printf("%d\n", $(NF-9))}')
echo "$CPU_USAGE " | awk '{ printf(" CPU: %6s%% \n", $1)}'
