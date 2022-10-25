#!/bin/sh
# By JMVA, VIDAL & ASTUDILLO Ltda, 2022
# www.vidalastudillo.com

#
# Updates the autoboot.txt to tell a RaspberryPi to boot from the partition A
# 

echo "[all]
tryboot_a_b=1
boot_partition=3
[tryboot]
boot_partition=2
" > '/persistent/autoboot.txt'
echo "Next reboot will load from: boot_b"
