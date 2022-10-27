#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Performs actions once `SWUpdate` has written the partitions
#


# Forces an immediate disk update
sync

# Reboots asking to use the updated set of partitions
rebootp '0 tryboot'
