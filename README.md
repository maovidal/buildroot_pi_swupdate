# ⚠️ This is a work in progress ⚠️

This is not yet functional. Currently neither the `tryboot` mechanism nor `SWUpdate` are working:

- `Tryboot` always boots from the `A` set.
- `SWUpdate` is expected to be implemented (once `tryboot` works) using as a reference an internal working project.

There are 2 components to test: which `boot` and which `rootfs` the device loads when a `reboot` as been issued.

The following test were expected to result, however the `CM4` always loads from `boot_a`:


1. On the first boot, it is expected that the `CM4` boots from `boot_a`.

To check it, in a terminal, `ls /dev/ttyAMA*` should report only `/dev/ttyAMA1` as `config.txt` from `boot_a` only enables `UART 1`.

2. Rebooting it with `reboot 2` should load the `boot_b`.

Now, `ls /dev/ttyAMA*` should report only `/dev/ttyAMA2` as `config.txt` from `boot_b` only enables `UART 2`.

3. Now, rebooting it with `reboot '1 tryboot'` should load the `boot_a` with a `tryboot.txt` that ENABLES booth `UART 1` and  `UART 2`.

That can be checked with `ls /dev/ttyAMA*` that should report `/dev/ttyAMA1` and `/dev/ttyAMA2`.

4. Finally, rebooting it with `reboot '2 tryboot'` should load the `boot_b` with a `tryboot.txt` that DISABLES booth `UART 1` and  `UART 2`.

That can be checked with `ls /dev/ttyAMA*` that should report nothing.


The current `rootfs` can be checked with `lsblk`, that in the case of the `rootfs_a` its mountpoint is marked with `/` for the `mmcblk0p5`:

```
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
mmcblk0      179:0    0 29.1G  0 disk 
|-mmcblk0p1  179:1    0   64M  0 part /boot_a
|-mmcblk0p2  179:2    0   64M  0 part /boot_b
|-mmcblk0p3  179:3    0    1M  0 part 
|-mmcblk0p4  179:4    0    1K  0 part 
|-mmcblk0p5  179:5    0  512M  0 part /
`-mmcblk0p6  179:6    0  512M  0 part 
mmcblk0boot0 179:32   0    4M  1 disk 
mmcblk0boot1 179:64   0    4M  1 disk 
```

Naturally, if `rootfs_b` were loaded, that `/` would be associated to the `mmcblk0p6` partition.

Sadly, none of the `reboot` instructions is wroking as expected.

If you would like to help, please drop me a message creating an Issue or with a message in this post: https://forums.raspberrypi.com/viewtopic.php?p=2045449#p2045449

Thank you!


# Description

The purpose of this repository is to generate an image tested on `buildroot 2022.08.1` that can be flashed on the internal eMMC of the `Raspberry Pi Compute Module 4` providing a mechanism to update its filesystem via a web page.

That mechanism considers a redundant approach which is implemented with two sets of partitions named A and B.

When the device is running from either of those set of partitions and is requested to perform an image update, it will prepare the set that is not currently in use with the new data received on its webpage and it will restart itself once the update has been completed.

If succeded, it will keep track of it to use the new set of partitions across restarts. Otherwise, on a failed update, the device will keep using the set that worked before the update.


## Under the hood

[tryboot][tryboot] is a Raspberry Pi native mechanism responsible to switch partitions at boot time when asked by a previous reboot.

[SWUpdate][swupdate] on the other hand, is in charge of providing:
- A webpage to receive the new image.
- The update mechanism including its completion (making it permanent) once restarted and proved correct.

The following partitions will be created on the device's eMMC:

- `boot_a`: An image that contains the boot information when the set A is the working one.
- `boot_b`: An image that contains the boot information when the set B is the working one.
- `persistent`: a small non volatile VFAT partition to keep the results of the state / transition of the image and other information that should be kept among restarts.
- `rootfs_a`: An image with the root filesystem when the set A is the working one.
- `rootfs_b`: An image with the root filesystem when the set B is the working one.


# Quick setup

Besides using this repo in your existing Buildroot installation using the [external mechanism][br2_external], there is also the option to use this [docker-buildroot repo][docker_buildroot] that provides a fast and convenient way to start working right away and keep multiple and independent instances for different targets at the same time.

Those are the instructions for the later case, as the ones to use your existing Buildroot installation are contained in Buildroot's documentation:

1. Get a clone of [docker-buildroot][docker_buildroot], if not already present in your system:

``` shell
git clone https://github.com/vidalastudillo/docker-buildroot
```

2. Get a clone of this repo to be placed at the folder `externals/pi_swupdate`:

``` shell
git clone https://github.com/maovidal/buildroot_pi_swupdate externals/pi_swupdate
```

3. Build the Docker image, if not already present in your system:

``` shell
docker build -t "advancedclimatesystems/buildroot" .
```

4. Create a [data-only container][data-only]. The name will be used on the scripts to refer to this spacific build:

``` shell
docker run -i --name br_output_PiSWU_CM4 advancedclimatesystems/buildroot /bin/echo "Data only for SWUpdate on CM4."
```

This container has 2 volumes at `/root/buildroot/dl` and `/buildroot_output`.
Buildroot downloads all data to the first volume, the last volume is used as build cache, cross compiler and build results.

5. Setup the new external folder and load the default configuration:

``` shell
./externals/pi_swupdate/run_cm4.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate menuconfig
./externals/pi_swupdate/run_cm4.sh make cm4_defconfig
```

These are the two relevant folders on your host:

- `externals/pi_swupdate/cm4`: the new external folder with the configs and other related files for this CM4 board.
- `images/pi_swupdate/cm4`: with your valuable results.

Also, the `target/pi_swupdate/cm4` folder is provided just to ease checking the building process.


# Usage

A small script has been provided to make using the container a little easier.
It's located at the folder `./externals/pi_swupdate/run_cm4.sh` which is a modified version of the one at `./scripts/run.sh`.

This modified script uses the `data only` container defined exclusively for this `SWUpdate on CM4` and produces the output separated in the `pi_swupdate/cm4` folders.

Then you can use usual commands like this:

``` shell
./externals/pi_swupdate/run_cm4.sh make menuconfig
./externals/pi_swupdate/run_cm4.sh make linux-rebuild
./externals/pi_swupdate/run_cm4.sh make linux-menuconfig
./externals/pi_swupdate/run_cm4.sh make all
```


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
