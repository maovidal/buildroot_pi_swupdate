#!/bin/sh


set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error when substituting.


# Calls the post-build for autoboot, as this variant also needs all its content.
sh ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/post-build_autoboot.sh

# Provides a file with the Device identification
install -D -m 0644 ${BR2_EXTERNAL_PISWU_CFG_PATH}/board/raspberrypi/pi2/id.device ${BINARIES_DIR}/persistent/id.device
