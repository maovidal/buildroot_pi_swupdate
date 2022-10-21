#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Performs the following actions once SWUpdate has written the partitions
# with updated content:
#
# 1. Reboots the device asking to use the set of paritions just updated.
#


# Gets the current partition
sh /etc/swupdate/current_partition.sh
current_partition=$?

# Forces an immediate disk update
sync

# Reboots asking to use the updated set of partitions
if [ "$current_partition" -eq 100 ] ; then

    rebootp 3

elif [ "$current_partition" -eq 200 ] ; then

    rebootp 2

else

    # Decides to halt the system
    echo "ERROR: The current partition is not the expected."
    echo "The device will halt to prevent further damage."
    halt

fi
