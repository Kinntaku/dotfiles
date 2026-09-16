#!/bin/bash

podman run --init -it --rm \
	--ipc=host \
	--userns=keep-id \
	-e DISPLAY=$DISPLAY \
	-e _JAVA_AWT_WM_NONREPARENTING=1 \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v ~/Documents/matlab:/home/matlab/Documents/matlab:Z \
	-v $DOTFILES/software_file/matlabR2022b/license.lic:/opt/matlab/R2022b/licenses/license.lic:ro \
	-v $DOTFILES/software_file/matlabR2022b/libmwlmgrimpl.so:/opt/matlab/R2022b/bin/glnxa64/matlab_startup_plugins/lmgrimpl/libmwlmgrimpl.so:ro \
	-w /home/matlab/Documents/matlab \
	--entrypoint /bin/bash \
	mathworks/matlab:R2022b
