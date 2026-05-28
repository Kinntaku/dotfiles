#!/bin/zsh

source ~/.zshrc

sudo fuser -k -9 /dev/nvidia* 

sudo rmmod nvidia_drm
sudo rmmod nvidia_modeset
sudo rmmod nvidia_uvm
sudo rmmod nvidia

echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers/nvidia/unbind
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers/snd_hda_intel/unbind 

sudo modprobe vfio-pci



echo "vfio-pci" | sudo tee /sys/bus/pci/devices/0000:01:00.0/driver_override
echo "vfio-pci" | sudo tee /sys/bus/pci/devices/0000:01:00.1/driver_override

echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers_probe
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers_probe

lspci -k | grep -A 2 -i nvidia


VM_NAME="win10"
URI="qemu:///system"

echo "Starting $VM_NAME..."
virsh -c $URI start $VM_NAME

while [ "$(virsh -c $URI domstate $VM_NAME)" != "running" ]; do
    sleep 2
done

looking-glass-client -f -m 100 -f /dev/kvmfr0 &
rclone serve webdav "/home/kinntaku/Documents/KVM/WIN10_22H2/" --addr 192.168.122.1:8080

disown