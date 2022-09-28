#!/bin/bash

set -e
set -T
set -E
set -o pipefail

size_multiplier="$1" # yep, its a string.
echo "<-----|${size_multiplier}|----->"

# round $1
function round() {
    round=$(printf %.2f "$1")
    echo "${round%???}" # strip .00d
}

[[ $(bc -l <<<"$size_multiplier < 1") -eq 1 ]] && pixels_to_outline=$(round "$(bc -l <<<"4 * $size_multiplier")")

# $1: file to outline
function outline() {
    local file="$1"
    if [[ -n $pixels_to_outline ]]; then
        convert "$file" -bordercolor none -background '#404049' -alpha background -channel A -blur "$pixels_to_outline" -level 0,0% "$file"
    else
        python3 outline.py "$file" "$size_multiplier" "$file"
    fi
}

renderer="resvg"
[[ -f ./resvg ]] && renderer="./resvg"
renderer+=" --shape-rendering crispEdges"

# $1: size
# $2: in
# $3: out
function render() {
    local size="$1"
    local in="$2"
    local out="$3"
    $renderer -w "$size" -h "$size" "$in" "$out"
}

# python **
function multiply_rounded() {
    round "$(bc -l <<<"$1*$2")"
}

echo -e "[4] icon.svg ➔ icon.png"
render 128 icon.svg icon.png &

shopt -s globstar
for i in _src_/**/*.svg; do
    while [ "$(jobs -r | wc -l)" -ge 10 ]; do sleep .1; done
    [[ $i == *"template"* ]] && continue
    name="${i%.svg}.png"
    name="${name//_src_/}"
    path="_original_$name" # _original_/file
    if [[ -f $path ]]; then
        size=$(multiply_rounded "$(identify -format '%w' "$path")" "$size_multiplier")
        base=$(basename "$name")
        mkdir -p sprites-override"${name//$base/}"
        out="sprites-override$name"
        #shellcheck disable=SC2143
        if [[ 
            ($name == *"turrets"* && $name != *"heat"* && $name != *"bases"* && $name != *"top"* && $name != *"liquid"*) ||
            (-n $(grep -F "$name" "manual_outline")) ]]; then
            (render "$size" "$i" "$out" && outline "$out") &
        else
            render "$size" "$i" "$out" &
        fi

        echo -e "[${size_multiplier}] $i ➔ $out"
    else
        echo -e "::warning file=${i}::No corresponding sprite" >&2
    fi
done
wait
