#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Removes a Flag stored in the non volatile memory that means
# the set A of partitions is being updated.
#


# $ stores the exit code of the last command
if [ $? -eq 0 ] ; then
    rm -r /persistent/UpdatingSetA
    # Forces an immediate disk update
    sync
    echo "Flag Removed: Updating Set A"
fi
