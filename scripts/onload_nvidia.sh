#!/bin/zsh
source ~/.zshrc

VM_NAME="win10"
URI="qemu:///system"

echo "Closing $VM_NAME..."
virsh -c $URI shutdown $VM_NAME

while [ "$(virsh -c $URI domstate $VM_NAME)" != "shut off" ]; do
    sleep 2
    echo -n "."
done

# 移除驱动覆盖
echo "" | sudo tee /sys/bus/pci/devices/0000:01:00.0/driver_override
echo "" | sudo tee /sys/bus/pci/devices/0000:01:00.1/driver_override

# 解绑vfio
echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind

sudo modprobe nvidia
sudo modprobe nvidia_drm
sudo modprobe nvidia_modeset
sudo modprobe nvidia_uvm

echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers_probe
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers_probe
