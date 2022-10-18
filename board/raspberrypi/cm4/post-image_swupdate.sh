#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage_swupdate.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

# exit $?

echo "********** SWUpdate Image Creation **********"
echo "${PRODUCT_NAME}"

PRODUCT_NAME="MyProduct"
IMG_FILES="sw-description boot_a.vfat boot_b.vfat rootfs.ext4.gz"

SWDESCRIPTION_DIR=$(dirname $0)

# Gets the current sw-description to be used in this image
cp ${SWDESCRIPTION_DIR}/sw-description ${BINARIES_DIR}/sw-description

# Creates the image including every file indicated by IMG_FILES
pushd ${BINARIES_DIR}
for i in ${IMG_FILES};do
	echo $i;
done | cpio -ovL -H crc > ${PRODUCT_NAME}.swu
popd
