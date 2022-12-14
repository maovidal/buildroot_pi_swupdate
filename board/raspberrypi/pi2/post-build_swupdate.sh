#!/bin/sh


set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error when substituting.


# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Merveilleux autoboot
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/generic/autoboot.txt ${BINARIES_DIR}/autoboot.txt

# Base config.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/config_base.txt ${BINARIES_DIR}/config_base.txt

# Every boot image receives a custom cmdline.txt, config.txt and tryboot.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/cmdline_a.txt ${BINARIES_DIR}/rpi-firmware_a/cmdline.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/cmdline_b.txt ${BINARIES_DIR}/rpi-firmware_b/cmdline.txt

install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/config_a.txt ${BINARIES_DIR}/rpi-firmware_a/config.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/config_b.txt ${BINARIES_DIR}/rpi-firmware_b/config.txt

# Helpers to set a new boot partition
install -m 0755 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/generic/set_boot_partition_a.sh ${TARGET_DIR}/usr/bin/set_boot_partition_a.sh
install -m 0755 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/generic/set_boot_partition_b.sh ${TARGET_DIR}/usr/bin/set_boot_partition_b.sh

# Mount partitions
if [ -e ${TARGET_DIR}/etc/fstab ]; then
	# Persistent (Where autoboot.txt resides)
	grep -qE '/dev/mmcblk0p1' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p1 /persistent vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
	# Boot_A
	grep -qE '/dev/mmcblk0p2' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p2 /boot_a vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
	# Boot_B
	grep -qE '/dev/mmcblk0p3' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p3 /boot_b vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi

# Provides a file with the Device identification
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/id.device ${BINARIES_DIR}/persistent/id.device
