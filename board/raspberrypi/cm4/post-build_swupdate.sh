#!/bin/sh

set -u
set -e

# Calls the post-build for autoboot, as this variant also needs all its content.
sh ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/post-build_autoboot.sh

# Provides a file with the Device identification
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/cm4/id.device ${BINARIES_DIR}/persistent/id.device
