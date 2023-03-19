#!/bin/bash
file=$1
image=$2
line=$(($(wc -l <"$file") - 2))
img="$(base64 "$image" -w 0)"
size="$(identify -format "width='%w' height='%h'" "$image")"
sed -i "${line}i><g style=\"display:none;opacity:0.5\"><image xlink:href=\"data:image/png;base64,${img}\" ${size} style=\"image-rendering:pixelated\"></image></g" "$file"
