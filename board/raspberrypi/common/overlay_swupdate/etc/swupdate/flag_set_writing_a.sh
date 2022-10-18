#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Sets a Flag stored in the non volatile memory that means
# the set A of partitions is being updated.
#


# $ stores the exit code of the last command
if [ $? -eq 0 ] ; then
    touch /persistent/UpdatingSetA
    # Forces an immediate disk update
    sync
    echo "Flag Set: Updating Set A"
fi
