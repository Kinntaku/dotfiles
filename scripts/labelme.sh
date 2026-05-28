#!/bin/bash
export QT_QPA_PLATFORM=xcb
micromamba run -n labelme labelme &
disown
