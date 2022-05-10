#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as img
import os
import sys

# get the path/directory
folder_dir = sys.argv[1]

originalsize = 0
resizedsize = 0

for root, dirs, files in os.walk(folder_dir, topdown=False):
    for name in files:
        if name.endswith('.png'):
            filename = os.path.join(root, name)
            print(filename)

            image = img.imread(filename)
            image = np.asarray(image)
            originalsize += image.shape[0] * image.shape[1]

            # remove first and last row if their alpha channel is all 0
            while image.shape[0] > 2 and np.all(image[0] == 0) and np.all(image[-1] == 0):
                image = image[1:-1]

            # remove first and last column if their alpha channel is all 0
            while image.shape[1] > 2 and np.all(image[:, 0] == 0) and np.all(image[:, -1] == 0):
                image = image[:, 1:-1]
            resizedsize += image.shape[0] * image.shape[1]
            plt.imsave(filename, image)

print("Original size:", originalsize)
print("Resized size:", resizedsize)
print(f"Reduction: {1 - resizedsize / originalsize: %}", )
