#!/bin/bash

PASSWORD="159273"

DEVICE_PATH="/sys/bus/i2c/devices/i2c-ASUF1204:00"
UNBIND_CMD="echo 'i2c-ASUF1204:00' > /sys/bus/i2c/devices/i2c-ASUF1204:00/driver/unbind"
BIND_CMD="echo 'i2c-ASUF1204:00' > /sys/bus/i2c/drivers/i2c_hid_acpi/bind"
if [ -d "${DEVICE_PATH}/driver" ]; then
	echo "$PASSWORD" | sudo -S sh -c "${UNBIND_CMD}"
else
	echo "$PASSWORD" | sudo -S sh -c "${BIND_CMD}"
fi
