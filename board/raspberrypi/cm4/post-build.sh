#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Every boot image receive a custom cmdline.txt
# Each points to its own rootfs partition.
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/cmdline_a.txt ${BINARIES_DIR}/rpi-firmware_a/cmdline.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/cmdline_b.txt ${BINARIES_DIR}/rpi-firmware_b/cmdline.txt

# A tryboot.txt for each set of partitions is also provided in order to
# have available the tryboot mechanism.
# Those don't provide an special function compared to the original config.
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/config.txt ${BINARIES_DIR}/rpi-firmware_a/tryboot.txt
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/config.txt ${BINARIES_DIR}/rpi-firmware_b/tryboot.txt
