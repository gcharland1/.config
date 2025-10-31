#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 input.pdf"
    exit 1
fi

INPUT="$1"
OUTPUT="${1//.pdf/_booklet.pdf/}"

# 1. Count pages
PAGES=$(pdftk "$INPUT" dump_data | grep NumberOfPages | awk '{print $2}')

# 2. Pad to multiple of 4
PADDED="$INPUT.padded.pdf"
REMAINDER=$(( PAGES % 4 ))
if [[ $REMAINDER -ne 0 ]]; then
    NEED=$(( 4 - REMAINDER ))
    echo "Padding with $NEED blank page(s) to reach a multiple of 4..."
    # Generate blank.pdf (one empty page) if it doesn't exist
    BLANK=/tmp/blank.pdf
    if [[ ! -f "$BLANK" ]]; then
        # Create a single blank page using pdftk
        echo "" | ps2pdf -sPAPERSIZE=a4 - "$BLANK"
    fi
    # Append the necessary blanks
    EXTRA=""
    for ((i=0; i<NEED; i++)); do
        EXTRA="$EXTRA $BLANK"
    done
    pdftk "$INPUT" $EXTRA cat output "$PADDED"
else
    cp "$INPUT" "$PADDED"
fi

TOTAL=$(pdftk "$PADDED" dump_data | grep NumberOfPages | awk '{print $2}')

# 3. Build booklet order
# The pattern: For each sheet we need pages in order:
#   last, first, second, second_last
#   last-2, third, fourth, last-3
#   ...
ORDER=()
LEFT=1
RIGHT=$TOTAL
while (( LEFT < RIGHT )); do
    ORDER+=("$RIGHT" "$LEFT" "$((LEFT+1))" "$((RIGHT-1))")
    LEFT=$((LEFT+2))
    RIGHT=$((RIGHT-2))
done

ORDER_STR=$(IFS=' '; echo "${ORDER[*]}")

echo "Reordering pages as: $ORDER_STR"
pdftk "$PADDED" cat $ORDER_STR output "$OUTPUT"

echo "Booklet PDF created: $OUTPUT"
