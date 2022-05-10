#!/bin/bash

size_multiplier="$1" # yep, its a string.

clr=$(echo "print(round($size_multiplier * 7))" | python)

recurse() {
    for i in "$1"/*; do
        if [ -d "$i" ]; then
            recurse "$i"
        elif [ -f "$i" ]; then
            if [[ $i == *"template"* || "${i: -4}" != ".svg" ]]; then
                exit 0
            fi
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
                if [[ $name == *"turrets"* && $name != *"heat"* && $name != *"bases"* && $name != *"top"* && $name != *"liquid"* ]]; then
                    python3 outline.py "$out" "$size_multiplier" "$out"
                fi
                echo -e "\033[38;2;0;100;0m[$size_multiplier]\033[38;2;100;100;$clr""m $i ➔ $out\033[0m"
            else
                echo -e "\033[31;1;4m[ohno]: no corresponding sprite for $i\033[0m" >&2
            fi
        fi
    done
}

recurse "_src_"
