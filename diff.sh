#!/bin/bash

set -e
set -T
set -E
set -o pipefail

root_path=$(pwd)

echo ::group::render
./export.sh 1 --no
echo ::endgroup::

echo ::group::diff

cd sprites-override

cat >simmilarity.py <<EOF
#!/usr/bin/env python3

def avg(ls):
  return sum(ls) / len(ls)

ls = [
EOF
chmod +x simmilarity.py
shopt -s globstar
for i in **/*.png; do
    if grep -q -F "$i" "$root_path/diff_overrides"; then
        continue
    fi
    original_path="$root_path/_original_/$i"
    rendered_path="$root_path/sprites-override/$i"
    dissimilarity="$(dssim "$original_path" "$rendered_path" | awk '{print $1}')"
    if [[ $(bc -l <<<"$dissimilarity <.15") -ne 1 ]]; then
        errors=1
        svg_path="_src_/${i%.png}.svg"
        echo "::error file=$svg_path,title=Does not match original::This file is not similar ($dissimilarity) to _original_/$i"
    else
        if [[ $(bc -l <<<"$dissimilarity == 0") -eq 1 ]]; then
            echo "[$i]: exactly the same"
        else
            echo "[$i]: $dissimilarity dissimilar"
            echo -n "$dissimilarity," >>simmilarity.py
        fi
    fi
done
echo -e "]\nprint(round(abs(avg(ls * 100) - 100), 3))" >>simmilarity.py

[[ -f "$GITHUB_STEP_SUMMARY" ]] &&
    echo "# $(./simmilarity.py)% similar" >"$GITHUB_STEP_SUMMARY"
echo "[average]: $(./simmilarity.py)% similar"

[[ -n "$errors" ]] && exit 1 # for github actions to report a failure

echo ::endgroup::
