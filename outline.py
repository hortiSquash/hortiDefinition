#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from sys import argv
from PIL import Image, ImageFilter, ImageDraw


def outline(filename: str, size: float, color: tuple = (64, 64, 73)) -> Image:
    img = Image.open(filename)
    X, Y = img.size
    edge = img.filter(ImageFilter.FIND_EDGES).load()
    stroke = Image.new(img.mode, img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(stroke)
    for x in range(X):
        for y in range(Y):
            if edge[x, y][3] > 0:
                draw.ellipse((x-size, y-size, x+size, y+size),
                             fill=color)
    stroke.paste(img, (0, 0), img)
    return stroke


img = outline(argv[1], float(argv[2]) * 3)
img.save(argv[3])
