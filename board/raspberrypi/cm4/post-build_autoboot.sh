#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Merveilleux autoboot
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/common/autoboot.txt ${BINARIES_DIR}/autoboot.txt

# Every boot image receives a custom cmdline.txt, config.txt and tryboot.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/cmdline_a_autoboot.txt ${BINARIES_DIR}/rpi-firmware_a/cmdline.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/cmdline_b_autoboot.txt ${BINARIES_DIR}/rpi-firmware_b/cmdline.txt

install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/config_a.txt ${BINARIES_DIR}/rpi-firmware_a/config.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/config_b.txt ${BINARIES_DIR}/rpi-firmware_b/config.txt

install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/tryboot_a.txt ${BINARIES_DIR}/rpi-firmware_a/tryboot.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/tryboot_b.txt ${BINARIES_DIR}/rpi-firmware_b/tryboot.txt

# An indicator for the empty partition
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/common/empty ${BINARIES_DIR}/persistent/.dummy


# Mount partitions
if [ -e ${TARGET_DIR}/etc/fstab ]; then
	# Boot_A
	grep -qE '/dev/mmcblk0p5' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p5 /boot_a vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
	# Boot_B
	grep -qE '/dev/mmcblk0p7' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p7 /boot_b vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
	# Persistent
	grep -qE '/dev/mmcblk0p2' ${TARGET_DIR}/etc/fstab || \
	echo "/dev/mmcblk0p2 /persistent vfat defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi
