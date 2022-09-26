#!/bin/bash

set -e
set -T
set -E
set -o pipefail

size_multiplier="$1" # yep, its a string.
echo "<-----|${size_multiplier}|----->"

shopt -s globstar

render="resvg"
[[ -f ./resvg ]] && render="./resvg"
render+=" --shape-rendering crispEdges"

# python **
function multiply_rounded() {
    round=$(printf %.2f "$(bc -l <<<"$1*$2")")
    echo "${round%???}"
}

echo -e "[4] icon.svg ➔ icon.png"
$render -w 128 -h 128 icon.svg icon.png &

for i in _src_/**/*.svg; do
    while [ "$(jobs -r | wc -l)" -ge 10 ]; do sleep .1; done
    [[ $i == *"template"* ]] && continue
    name="${i%.svg}.png"
    name="${name//_src_/}"
    path="_original_$name" # _original_/file
    if [[ -f $path ]]; then
        size=$(identify -format '%w' "$path") # all mindustry sprites are square
        size=$(multiply_rounded "$size" "$size_multiplier")
        base=$(basename "$name")
        mkdir -p sprites-override"${name//$base/}"
        out="sprites-override$name"
        if [[ $name == *"turrets"* && $name != *"heat"* && $name != *"bases"* && $name != *"top"* && $name != *"liquid"* ]]; then
            (
                $render -w "$size" -h "$size" "$i" "$out"
                python3 outline.py "$out" "$size_multiplier" "$out"
            ) &
        else
            $render -w "$size" -h "$size" "$i" "$out" &
        fi
        echo -e "[${size_multiplier}] $i ➔ $out"
    else
        echo -e "::warning file=${i}::No corresponding sprite" >&2
    fi
done
wait
