#!/bin/bash

SHARE_DIR="$HOME/Documents/VM/shared_files/"
OVMF_VARS="$HOME/Documents/VM/OVMF_VARS.fd"
DISK="$HOME/Documents/VM/win10.qcow2"
WIN_ISO="$HOME/Downloads/cn_windows_10_enterprise_ltsc_2019_x64_dvd_9c09ff24.iso"
VIRTIO_ISO="$HOME/Downloads/virtio-win-0.1.302.iso"

ISO_ARGS=()
[[ "$1" == "install" ]] && ISO_ARGS=(
	-drive "file=$WIN_ISO,media=cdrom,readonly=on"
	-drive "file=$VIRTIO_ISO,media=cdrom,readonly=on"
)

__NV_PRIME_RENDER_OFFLOAD=1 \
	__GLX_VENDOR_LIBRARY_NAME=nvidia

SOCK="/tmp/win10share.sock"

rm -f "$SOCK"

/usr/lib/virtiofsd \
	--socket-path="$SOCK" \
	--shared-dir="$SHARE_DIR" &

VIRTIOFSD_PID=$!

cleanup() {
	kill "$VIRTIOFSD_PID" 2>/dev/null
	rm -f "$SOCK"
}
trap cleanup EXIT

while [ ! -S "$SOCK" ]; do
	sleep 0.05
done

qemu-system-x86_64 \
	-name "Win10-LTSC" \
	-enable-kvm \
	-machine q35 \
	-cpu host \
	-smp 16,sockets=1,cores=8,threads=2 \
	-m 8G \
	-object memory-backend-memfd,id=mem,size=8G,share=on \
	-numa node,memdev=mem \
	\
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
	-drive if=pflash,format=raw,file=$OVMF_VARS \
	\
	-drive file="$DISK",format=qcow2,if=none,id=systemdisk \
	-device virtio-blk-pci,drive=systemdisk \
	\
	"${ISO_ARGS[@]}" \
	\
	-chardev socket,id=char_fs,path="$SOCK" \
	-device vhost-user-fs-pci,chardev=char_fs,tag=shared \
	-device virtio-vga-gl \
	-display sdl,gl=on \
	\
	-device qemu-xhci \
	-device usb-tablet \
	-monitor unix:/tmp/qemu.sock,server=on,wait=off \
	-nic user,model=virtio-net-pci
