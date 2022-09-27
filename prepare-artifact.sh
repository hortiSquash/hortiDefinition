#!/bin/bash

echo "::group::artifact x$1"

l=$(pwd)
bash export.sh "$1"
# python3 trim.py "sprites-override"
tmp_folder="$HOME/temp_$1"
[[ -d $tmp_folder ]] && rm -r "$tmp_folder"
mkdir "$tmp_folder"
cp -r "sprites-override" "mod.json" "README.md" "icon.png" "$tmp_folder"
#shellcheck disable=SC2164
cd "$tmp_folder"
# tree .
jq ".texturescale = $(bc -l <<<"1/$1")" mod.json | sponge mod.json
jq ".name = \"$(jq -r ".name" mod.json) x$1\"" mod.json | sponge mod.json

zip -qr "hortiDefinition_x$1.zip" .
mv "hortiDefinition_x$1.zip" "$l"
cd "$l" && rm -r "$tmp_folder"

echo "::endgroup::"
