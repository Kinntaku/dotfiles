#!/bin/bash

ENV_NAME="lizard"
HOST_MICROMAMBA_DIR="/home/kinntaku/micromamba"
HOST_PROJECT_DIR="$HOME/temp/BCQ"
CONTAINER_PROJECT_DIR="/root/BCQ"
CUDA_IMAGE="nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04"
HOST_MICROMAMBA_BIN="/usr/bin/micromamba"

podman run --rm -it \
	--device nvidia.com/gpu=all \
	-v "${HOST_MICROMAMBA_BIN}":/usr/bin/micromamba:ro \
	-v "${HOST_PROJECT_DIR}":"${CONTAINER_PROJECT_DIR}" \
	-v "${HOST_MICROMAMBA_DIR}":"${HOST_MICROMAMBA_DIR}" \
	"${CUDA_IMAGE}" \
	bash -c '
			ENV_NAME="'"${ENV_NAME}"'"
			HOST_MICROMAMBA_DIR="'"${HOST_MICROMAMBA_DIR}"'"
			if ! grep -q "MAMBA_EXE" ~/.bashrc; then
				{
					echo ""
					echo "export MAMBA_EXE=\"/usr/bin/micromamba\""
					echo "export MAMBA_ROOT_PREFIX=\"${HOST_MICROMAMBA_DIR}\""
					echo "eval \"\$(/usr/bin/micromamba shell hook --shell bash --root-prefix /root/micromamba 2>/dev/null)\""
					echo "micromamba activate ${ENV_NAME}"
				} >> ~/.bashrc
			fi
			exec bash --login -i
	'
