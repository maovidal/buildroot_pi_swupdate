#!/bin/sh

# Original at PINN:
# https://github.com/procount/pinn/tree/master/buildroot/package/rebootp

killall dropbear && /usr/bin/rebootp $1 &
