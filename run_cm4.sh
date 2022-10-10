#!/bin/bash
# Start container and start process inside container.
# Specific for U-Boot SWUpdate running of Raspberry Pi Compute Module 4
set -e

OUTPUT_DIR=/buildroot_output
BUILDROOT_DIR=/root/buildroot

# At least on macOS, exposing the full OUTPUT_DIR to the host, seems to impact
# negatively the speed of the builds and frequent errors building libraries.
# That's why we just expose images and target

DOCKER_RUN="docker run
    --rm
    -ti
    --volumes-from br_output_PiSWU_CM4
    -v $(pwd)/.ssh:/root/.ssh
    -v $(pwd)/externals:$BUILDROOT_DIR/externals
    -v $(pwd)/rootfs_overlay:$BUILDROOT_DIR/rootfs_overlay
    -v $(pwd)/images/pi_swupdate/cm4:$OUTPUT_DIR/images
    -v $(pwd)/target/pi_swupdate/cm4:$OUTPUT_DIR/target
    -v $(pwd)/graphs/pi_swupdate/cm4:$OUTPUT_DIR/graphs
    advancedclimatesystems/buildroot"

make() {
    echo "make O=$OUTPUT_DIR"
}

echo $DOCKER_RUN
if [ "$1" == "make" ]; then
    eval $DOCKER_RUN $(make) ${@:2}
else
    eval $DOCKER_RUN $@
fi
