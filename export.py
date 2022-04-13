#!/bin/python
import os

for subdir, dirs, files in os.walk('_src_'):
    for file in files:
        os.system(f"./export.sh {os.path.join(subdir, file)}")
