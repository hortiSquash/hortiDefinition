#!/bin/python
import os

for subdir, dirs, files in os.walk('_src_'):
    for file in files:
        nf = os.path.join(subdir, file)
        os.rename(nf, nf.replace('\r', '').replace('\n', ''))
