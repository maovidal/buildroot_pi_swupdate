#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Tells which set of partitions is in use.
# It is based on the identification of the partition where `/` is mounted.
#
# Returns:
# 100 if the current set of partitions is A.
# 200 if the current set of partitions is B.
# 1 if it can't be determined.
#

# $ stores the exit code of the last command
if [ $? -eq 0 ] ; then

    DEFINED_PARTITION_A='mmcblk0p5'
    DEFINED_PARTITION_B='mmcblk0p6'

    device=$(eval $(lsblk -oMOUNTPOINT,NAME -P | grep 'MOUNTPOINT="/"'); echo $NAME)

    # Evaluates if the current partition is A
    if [ "$device" = "${DEFINED_PARTITION_A}" ] ; then
        echo "Partition A is the current one."
        return 100
    else

        # Evaluates if the current partition is B
        if [ "$device" = "${DEFINED_PARTITION_B}" ] ; then
            echo "Partition B is the current one."
            return 200
        else
            echo "Warning: It can't be determined which partition is current."
            return 1
        fi
    fi
fi
