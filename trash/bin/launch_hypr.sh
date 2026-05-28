#!/bin/sh
export AQ_DRM_DEVICES=/dev/dri/card1
export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
exec start-hyprland