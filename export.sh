#!/bin/bash

size_multiplier="$1" # yep, its a string.
echo "<-----|${size_multiplier}|----->"

recurse() {
    for i in "$1"/*; do
        if [ -d "$i" ]; then
            recurse "$i"
        elif [ -f "$i" ]; then
            [[ $i == *"template"* || "${i: -4}" != ".svg" ]] && exit 0
            name="${i%.svg}.png"
            name="${name//_src_/}"
            base=$(basename "$name")
            found="_original_$name"
            if [[ -f $found ]]; then
                size=$(identify -format '%w' "$found") # all mindustry sprites are square
                size=$(echo "print(round($size * $size_multiplier))" | python)
                mkdir -p sprites-override"${name//$base/}"
                out="sprites-override$name"
                if [[ -f ./resvg ]]; then
                    ./resvg -w "$size" -h "$size" --shape-rendering crispEdges "$i" "$out"
                else
                    resvg -w "$size" -h "$size" --shape-rendering crispEdges "$i" "$out"
                fi
                [[ $name == *"turrets"* && $name != *"heat"* && $name != *"bases"* && $name != *"top"* && $name != *"liquid"* ]] && python3 outline.py "$out" "$size_multiplier" "$out"
                echo -e "[${size_multiplier}] $i ➔ $out"
            else
                echo -e "::warning file=${i}::No corresponding sprite" >&2
            fi
        fi
    done
}

recurse "_src_"
