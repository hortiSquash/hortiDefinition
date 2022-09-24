#!/bin/bash

l=$(pwd)
bash export.sh "$1"
# python3 trim.py "sprites-override"
tmp_folder="$HOME/temp_$1"
mkdir "$tmp_folder"
cp -r "sprites-override" "mod.hjson" "README.md" "icon.png" "$tmp_folder"
#shellcheck disable=SC2164
cd "$tmp_folder"
# tree .
bc -l <<<"1/$1" >>mod.hjson
cat mod.hjson
zip -qr "hortiDefinition_x$1.zip" .
mv "hortiDefinition_x$1.zip" "$l"
cd "$l" && rm -r "$tmp_folder"
