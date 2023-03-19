#!/bin/bash

set -e
set -T
set -E
set -o pipefail

root_path=$(pwd)

cd _original_
shopt -s globstar
files=()
for i in **/*.png; do
    original_path="$root_path/_original_/$i"
    [[ -f $original_path ]] || continue
    output_path="$root_path/_src_/${i%.png}.svg"
    [[ $1 != "force" && -f $output_path ]] && continue
    if grep -q -F "$i" "$root_path/create_overrides"; then continue; fi
    files+=("$original_path" "$output_path")
done
"$root_path/squares/svgtestc" "${files[@]}"
svgo "$root_path/_src_" -r -q --multipass --pretty --final-newline
