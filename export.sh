#!/bin/bash

size_multiplier=1

i=$1

if [[ $i == "_src_/template.svg" || "${i: -4}" != ".svg" ]]; then
    exit 0
fi
echo "Processing $i"
name="${i%.svg}.png"
name="${name//_src_/}"
base=$(basename "$name")
found=$(find sprites-override -type f -name "$base")
size=$(($(identify -format '%w' "$found") * size_multiplier)) # all mindustry sprites are square
mkdir -p render"${name//$base/}"
inkscape -z --export-area-snap --export-filename="render$name" --export-width="$size" --export-height="$size" "$i" # i hate the warnings
