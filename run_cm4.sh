#!/bin/bash
# Start container and start process inside container.
# Specific for SWUpdate running of Raspberry Pi Compute Module 4.
set -e

# Ensure the shared workspace volume exists
docker volume inspect buildroot_workspace >/dev/null 2>&1 || docker volume create buildroot_workspace

# --- Workspace & Storage ---
BUILDROOT_DIR=/root/buildroot
EXTERNAL_TREES_DIR=/buildroot_externals
OUTPUT_DIR=/workspace/outputs/pi_swupdate/cm4
CCACHE_LIMIT="50G"

# Detect if we are in an interactive terminal
[ -t 0 ] && TTY_FLAGS="-ti" || TTY_FLAGS=""

# At least on macOS, exposing the full OUTPUT_DIR to the host, seems to impact
# negatively the speed of the builds and frequent errors building libraries.
# That's why we just expose images and target
DOCKER_RUN="docker run
    --rm
    $TTY_FLAGS
    -v buildroot_workspace:/workspace
    -e OUTPUT_DIR=$OUTPUT_DIR
    -e BR2_CCACHE_DIR=/workspace/ccache
    -e BR2_DL_DIR=/workspace/dl
    -e CCACHE_MAXSIZE=$CCACHE_LIMIT
    -e CCACHE_BASEDIR=/workspace
    -e CCACHE_COMPILERCHECK=content
    -v $(pwd)/buildroot:$BUILDROOT_DIR
    -v $(pwd)/externals:$EXTERNAL_TREES_DIR
    -v $(pwd)/images/pi_swupdate/cm4:$OUTPUT_DIR/images
    -v $(pwd)/target/pi_swupdate/cm4:$OUTPUT_DIR/target
    -v $(pwd)/graphs/pi_swupdate/cm4:$OUTPUT_DIR/graphs
    ${BUILDROOT_IMAGE:-va_buildroot}"

make() {
    echo "make BR2_EXTERNAL=${EXTERNAL_TREES_DIR}/pi_swupdate O=$OUTPUT_DIR BR2_DL_DIR=/workspace/dl"
}

if [ "$1" == "make" ]; then
    eval $DOCKER_RUN $(make) ${@:2}
else
    eval $DOCKER_RUN $@
fi
