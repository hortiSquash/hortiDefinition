#!/bin/bash

size_multiplier=2

i=$1

if [[ $i == "_src_/template.svg" || "${i: -4}" != ".svg" ]]; then
    exit 0
fi

echo "Processing $i"
name="${i%.svg}.png"
name="${name//_src_/}"
base=$(basename "$name")
found=$(find sprites-override -type f -name "*$base*")
if [[ -n $found ]]; then
    chmod +x "$i"
    chmod +x "$found"
    size=$(($(identify -format '%w' "$found") * size_multiplier)) # all mindustry sprites are square
    mkdir -p render"${name//$base/}"
    if [[ -n $(man inkscape | grep -c "\-\-export\-width") ]]; then
        inkscape -z --export-area-snap --export-filename="render$name" --export-width="$size" --export-height="$size" "$i" # i hate the warnings
    elif [[ -n $(man inkscape | grep -c "\-\-export\-png") ]]; then
        inkscape -z --export-area-snap --export-png="render$name" --export-width="$size" --export-height="$size" "$i" # why does the cli change in ubuntu
    else
        man inkscape
    fi
fi
exit 0
