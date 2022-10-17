# Description

⚠️ This is a work in progress. `SWUpdate` is yet to be implemented, and the `autoboot` mechanism for the `Pi2` is not working yet ⚠️


The purpose of this repository is to generate images tested on `buildroot 2022.08.1` that provide a webpage to update the images of the `Raspberry Pi 2B` and the `Raspberry Pi Compute Module 4`.

That mechanism considers a redundant approach which is implemented with two sets of partitions named A and B.

When the device is running from either of those set of partitions and is requested to perform an image update, it will prepare the set that is not currently in use with the new data received on its webpage and it will restart itself once the update has been completed.

If succeded, it will keep track of it to use the new set of partitions across restarts. Otherwise, on a failed update, the device will keep using the set that worked before the update.


# Quick setup

Besides using this repo in your existing Buildroot installation using the [external mechanism][br2_external], there is also the option to use this [docker-buildroot repo][docker_buildroot] that provides a fast and convenient way to start working right away and keep multiple and independent instances for different targets at the same time.

Those are the instructions for the later case, as the ones to use your existing Buildroot installation are contained in Buildroot's documentation:

1. Get the docker container for `Buildroot`:

``` shell
# Get a clone of [docker-buildroot][docker_buildroot], if not already present in your system:
git clone https://github.com/vidalastudillo/docker-buildroot

# Get a clone of this repo to be placed at the folder `externals/pi_swupdate`:
git clone https://github.com/maovidal/buildroot_pi_swupdate externals/pi_swupdate

# Build the Docker image:
docker build -t "advancedclimatesystems/buildroot" .
```

2. Setup each [data-only containers][data-only] for the board and mechanism you want to use. Please note that:

- You can setup all of them and even run them simultaneously (Provided your hardware has enough resources to allow it).

- Each `data-only container` will contain 2 volumes at `/root/buildroot/dl` and `/buildroot_output`.

- To tell the `Builroot container` which `data-only container` to use, one helper script is provided for every `x` board and `y` mechanism named `scripts_x_y.sh` (Those scripts are described in the next section in this document).

- `Buildroot` downloads all data to the first volume, the last volume is used as build cache, cross compiler and build results organized like this:

    - `externals/pi_swupdate/x_y`: the new external folder with the configs and other related files.
    - `images/pi_swupdate/x_y`: with your valuable results.
    - Also, the `target/pi_swupdate/x_y` folder is provided just to ease checking the building process.

- `name` will be used on the scripts to refer to this specific build.


These are the available options:

* For the `Pi2` with `SWUpdate` support:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_Pi2 advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on Pi2."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_pi2.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate pi2_defconfig
```

* For the `CM4` with `SWUpdate` support:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_CM4 advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on CM4."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_cm4.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate cm4_defconfig
```

The next are meant to test the `tryboot` and/or the `autoboot` mechanisms. Those don't offer `SWUpdate` support.

* For the `Pi2` using the `tryboot` mechanism:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_Pi2_tryboot advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on Pi2 - Based on tryboot mechanism."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_pi2_tryboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate pi2_tryboot_defconfig
```

* For the `Pi2` using the `autoboot` mechanism:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_Pi2_autoboot advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on Pi2 - Based on autoboot mechanism."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_pi2_autoboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate pi2_autoboot_defconfig
```

* For the `CM4` using the `tryboot` mechanism:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_CM4_tryboot advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on CM4 - Based on tryboot mechanism."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_cm4_tryboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate cm4_tryboot_defconfig
```

* For the `CM4` using the `autoboot` mechanism:

``` shell
# Data-only container
docker run -i --name br_output_PiSWU_CM4_autoboot advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on CM4 - Based on autoboot mechanism."
```
``` shell
# Set the external mechanism and the default configuration
./externals/pi_swupdate/run_cm4_autoboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate cm4_autoboot_defconfig
```


# Building the images

A small helper script has been provided to make using the container a little easier for each board variant and mechanism:

The ones related to the Pi2 and CM4 boards, with SWUpdate support:

- `./externals/pi_swupdate/run_pi2.sh`
- `./externals/pi_swupdate/run_cm4.sh`

The ones just to test the `tryboot`, `autoboot` mechanisms:

- `./externals/pi_swupdate/run_pi2_tryboot.sh`
- `./externals/pi_swupdate/run_pi2_autoboot.sh`
- `./externals/pi_swupdate/run_cm4_tryboot.sh`
- `./externals/pi_swupdate/run_cm4_autoboot.sh`

All those scripts are modified versions of the one at `./scripts/run.sh` that use the `data only` container defined exclusively for each board and mechanism type and produce the output separated in the `pi_swupdate/` folders.

Then you can use usual commands like this in the case of the `CM4` board based on the `autoboot` mechanism:

``` shell
./externals/pi_swupdate/run_cm4_autoboot.sh make menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-rebuild
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make all
```


# Using the images

Once the image has been build it will be located in the folder `./images/pi_swupdate/` on your host, ie. `images/pi_swupdate/cm4_autoboot/sdcard.img`, that can be flashed to the `Pi` following the official Raspberry Pi documentation.

The update mechanism is provided by [SWUpdate][swupdate] with those particular functions:

- A webpage to receive the new image.
- The update mechanism including its completion (making it permanent) once restarted and proved correct.

The reboot mechanism is provided by a custom `rebootp` command implemented originally by the [PINN project][PINN_rebootp] because the original `reboot` command does not inject the partition number required to switch partitions.

The `autoboot` mechanism is used to allow `SWUpdate` to update the new partition to be used by the `Pi` once it has been proved to run successfully upon reboot.

While the `tryboot` is not used, during development was something considered. That is why a `vanilla` version (with no `SWUpdate`) to test this mechanism is available on this repo and another version for testing the `autoboot` is available as well. Here there are their details:


## Under the hood of the versions based on `tryboot`.

The following partitions will be created on the device's eMMC:

- `boot_a` located at `mmcblk0p1`: Contains the boot information when the set A is the working one.
- `boot_b` located at `mmcblk0p2`: Contains the boot information when the set B is the working one.
- `persistent` located at `mmcblk0p3`: A non volatile (of course) VFAT partition available to the user to keep information that will survive images updates.
- `rootfs_a` located at `mmcblk0p5`: The root filesystem when the set A is the working one.
- `rootfs_b` located at `mmcblk0p6`: The root filesystem when the set B is the working one.

Testing `tryboot` can be done as follows:

1. Starting the pi once energized:

2. Issue `rebootp 2`
The `Pi` will reboot into boot 2 and its default config.txt asks to load rootfs 6
You can check that with `./check.sh` that should report rootfs 6 as the mountpoint

3. Issue `rebootp 1`
The `Pi` will reboot into boot 1 and its default config.txt asks to load rootfs 5
You can check that with `./check.sh` reports rootfs 5 as the mountpoint

4. Issue `rebootp '2 tryboot'`
The `Pi` will reboot into boot 2 whose tryboot.txt has a cmdline_from_a that asks rootfs 5
You can check that with `./check.sh` reports rootfs 5 as the mountpoint

5. Issue `rebootp '1 tryboot'`
The `Pi` will reboot into boot 1 whose tryboot.txt has a cmdline_from_b that asks rootfs 6
You can check that with `./check.sh` reports rootfs 6 as the mountpoint


## Under the hood of the versions based on `autoboot`.

`autoboot.txt` is an undocumented mechanism of Raspberry Pi to boot from a particular partition.

The following partitions will be created on the device's eMMC:

- `persistent` located at `mmcblk0p1`: Contains the `autoboot.txt` file that will tell the `Pi` from which parition to boot. The `Pi2` variant also contains a file `bootcode.bin`.
- `boot_a` located at `mmcblk0p2`: Contains the boot information when the set A is the working one.
- `boot_b` located at `mmcblk0p3`: Contains the boot information when the set B is the working one.
- `rootfs_a` located at `mmcblk0p5`: The root filesystem when the set A is the working one.
- `rootfs_b` located at `mmcblk0p6`: The root filesystem when the set B is the working one.

Testing `autoboot` can be done as follows:

1. Starting the pi once energized:
The `Pi` will boot from 2 and use rootfs 5.

2. Issue `set_b_partition.sh` and then `reboot` or `rebootp`
The `Pi` will boot from 3 and use rootfs 6.

3. Issue `set_a_partition.sh` and then `reboot` or `rebootp`
The `Pi` will boot from 2 and use rootfs 5.

4. Issue `rebootp 3`
The `Pi` will reboot into boot 3 and its default config.txt asks to load rootfs 6
You can check that with `./check.sh` that should report rootfs 6 as the mountpoint

5. Issue `rebootp 2`
The `Pi` will reboot into boot 2 and its default config.txt asks to load rootfs 5
You can check that with `./check.sh` reports rootfs 5 as the mountpoint

Also, you can test `tryboot`

6. Issue `rebootp '3 tryboot'`
The `Pi` will reboot into boot 3 whose tryboot.txt has a cmdline_from_a that asks rootfs 5
You can check that with `./check.sh` reports rootfs 5 as the mountpoint

7. Issue `rebootp '2 tryboot'`
The `Pi` will reboot into boot 2 whose tryboot.txt has a cmdline_from_b that asks rootfs 6
You can check that with `./check.sh` reports rootfs 6 as the mountpoint


# License

This software is licensed under MIT License.

&copy; 2022 Mauricio Vidal.

[docker_buildroot]:https://github.com/vidalastudillo/docker-buildroot
[original_docker_buildroot_repo]:https://github.com/AdvancedClimateSystems/docker-buildroot
[buildroot]:http://buildroot.uclibc.org/
[data-only]:https://docs.docker.com/userguide/dockervolumes/
[br2_external]:http://buildroot.uclibc.org/downloads/manual/manual.html#outside-br-custom
[tryboot]:https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#fail-safe-os-updates-tryboot
[uboot]:https://u-boot.readthedocs.io/en/latest/
[swupdate]:https://sbabic.github.io/swupdate/swupdate.html
[PINN_rebootp]:https://github.com/procount/pinn/tree/master/buildroot/package/rebootp
