#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Performs the following actions before SWUpdate updates the partitions.
#
# 1. Places a FLAG on the non-volatile memory indicating set of partitions
#    that is being updated.
#


# $ stores the exit code of the last command
if [ $? -eq 0 ] ; then

    # Gets the current set of partitions
    sh /etc/swupdate/current.sh
    current_set=$?

    # Based on the current set of partitions where set a flag on the non
    # volatile memory, indicating which is the set of partitions being updated.
    if [ "$current_set" -eq 100 ] ; then

        sh /etc/swupdate/flag_set_writing_b.sh

    elif [ "$current_set" -eq 200 ] ; then

        sh /etc/swupdate/flag_set_writing_a.sh

    else

        # Decides to halt the system
        echo "ERROR: The current partition is not the expected."
        echo "The device will halt to prevent further damage."
        halt

    fi

fi
