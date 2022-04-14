#!/bin/bash

size_multiplier=2

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
            echo "_original_$name"
            base=$(basename "$name")
            found="_original_$name"
            if [[ -f $found ]]; then
                size=$(($(identify -format '%w' "$found") * size_multiplier)) # all mindustry sprites are square
                mkdir -p sprites-override"${name//$base/}"
                resvg -w "$size" -h "$size" --shape-rendering crispEdges "$i" "sprites-override$name"
            fi
        fi
    done
}

recurse "_src_"
