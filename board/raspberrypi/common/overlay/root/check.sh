#!/bin/sh

echo "The presence of loaded ports (On generic Waveshare Wireless Board):"
echo "ttyAMA0=debug, ttyAMA1=RS485_1, ttyAMA2=RS485_2"
ls /dev/ttyAMA*

echo "The current partitions and mountpoints"
lsblk
