#!/bin/bash

size_multiplier="$1" # yep, its a string.

recurse() {
    for i in "$1"/*; do
        if [ -d "$i" ]; then
            recurse "$i"
        elif [ -f "$i" ]; then
            if [[ $i == "_src_/template.svg" || "${i: -4}" != ".svg" ]]; then
                exit 0
            fi
            echo "Processing $i"
            name="${i%.svg}.png"
            name="${name//_src_/}"
            base=$(basename "$name")
            found="_original_$name"
            if [[ -f $found ]]; then
                size=$(identify -format '%w' "$found") # all mindustry sprites are square
                size=$(echo "print(round($size * $size_multiplier))" | python)
                mkdir -p sprites-override"${name//$base/}"
                if [[ -f ./resvg ]]; then
                    ./resvg -w "$size" -h "$size" --shape-rendering crispEdges "$i" "sprites-override$name"
                else
                    resvg -w "$size" -h "$size" --shape-rendering crispEdges "$i" "sprites-override$name"
                fi
            fi
        fi
    done
}

recurse "_src_"
