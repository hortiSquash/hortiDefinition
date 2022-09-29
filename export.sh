#!/bin/bash

set -e
set -T
set -E
set -o pipefail

size_multiplier="$1" # yep, its a string.

[[ $2 == "--no" ]] && no_outline=1

root_path="$(pwd)"

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
        python3 "$root_path"/outline.py "$file" "$size_multiplier" "$file"
    fi
}

# $1: size
# $2: in
# $3: out
function render() {
    resvg --shape-rendering crispEdges -w "$1" -h "$1" "$2" "$3"
}

# python **
function multiply_rounded() {
    round "$(bc -l <<<"$1*$2")"
}

# $1: output_path
function multiplied_size() {
    multiply_rounded "$(identify -format '%w' "$1")" "$size_multiplier"
}

echo -e "[4] icon.svg ➔ icon.png"
render 128 icon.svg icon.png &

cd _src_
shopt -s globstar
for i in **/*.svg; do
    while [ "$(jobs -r | wc -l)" -ge 10 ]; do sleep .1; done
    [[ $i == *"template"* ]] && continue
    r_path="${i%.svg}.png" # the folder relative to sprites_override, or _original_: units/gamma.png
    original_path="$root_path/_original_/$r_path"
    if [[ -f $original_path ]]; then
        output_path="$root_path/sprites-override/$r_path"
        [[ ! -d "${output_path%/*}" ]] && mkdir -p "${output_path%/*}" # dirname
        #shellcheck disable=SC2143
        if [[ 
            -z "$no_outline" &&
            (
            ($r_path == *"turrets"* && $r_path != *"heat"* && $r_path != *"bases"* && $r_path != *"top"* && $r_path != *"liquid"*) ||
            (-n $(grep -F "$r_path" "$root_path/manual_outline"))) ]]; then
            (render "$(multiplied_size "$original_path")" "$i" "$output_path" && outline "$output_path") &
        else
            render "$(multiplied_size "$original_path")" "$i" "$output_path" &
        fi

        echo -e "[${size_multiplier}] $r_path"
    else
        echo -e "::warning file=${i}::No corresponding sprite" >&2
    fi
done
wait
