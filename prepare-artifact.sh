#!/bin/bash

location=$(pwd)
bash export.sh "$1"
mkdir ../temp
cp -r ./* ../temp
if [[ -d ../temp ]]; then
    cd ../temp || exit 1
    find . -maxdepth 1 -not -name 'sprites-override' -not -name 'mod.*' -not -name 'README.md' -exec /bin/rm -rf '{}' \;
    # tree .
    tilesize=$(echo "print(round(32 * $1))" | python3)
    echo "$tilesize" >>mod.hjson
    cat mod.hjson
    zip -r "mod_scale_$1.zip" .

fi

mv "mod_scale_$1.zip" "$location"
cd "$location" || exit 1
rm -rf ../temp
