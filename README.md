# ⚠️ This is a work in progress ⚠️

**TODO:**

- Investigate possible corruptions of the filesystem, prevent them and provide a way to solve it.
- The current `web-app` at `/board/raspberrypi/generic/overlay_swupdate/var/www/swupdate/` is a copy of the one shipped with `SWUpdate 2021.04`. Investigate why a newer version can't be used. For reference, a copy from SWUpdate repo (from 22-10-18) is provided at the folder `swupdate_from_2022_10_18`.


**Pull requests are welcome!**


# Description

The purpose of this repository is to implement a mechanism to update a device that allows it to return to a previous working state in case the update fails.

The implemented approach considers:

- The device provides a webpage at http://<your_device_ip>:8080 to receive a new image.
- The device uses two redundant set of partitions, named A and B. Each set has a `boot` and a `rootfs`.
- The images are generated using `buildroot 2022.08.1` which implements `SWUpdate 2022.05`.
- The supported devices are `Raspberry Pi 2B` and `Raspberry Pi Compute Module 4`.

When the device is running from one of those sets of partitions and an update is requested, the device will:

1. Write the set of partitions that is not in use with the image received.
2. Once completed, the device will restart to test the updated set of partitions.
3. If it is able to boot, it will update a file that will tell it to use that set of partitions for the next boots.

In case that the process is interrupted at any point before the last step the device will keep using the set of partitions that was not updated.


**For the `CM4` it requires EEPROM updated to `pieeprom-2022-10-18.bin` at least**


## Under the hood

[SWUpdate][swupdate] deploys a web page to receive the new image provided by the user and writes it to the device.

The reboot mechanism is provided by a custom `rebootp` command implemented originally by the [PINN project][PINN_rebootp] because the original `reboot` command does not inject booth the partition number and tryboot arguments required to switch partitions.

An init script called `S80swupdate` is in charge of testing if the device is starting from the expected boot partition after an update has been performed making the change permanent for that case.

The [`autoboot` mechanism][autoboot] and its option [tryboot_a_b][tryboot_a_b] are implemented to let the device to idenfity the current working boot partition and the one to test when requested by a `rebootp` using the `tryboot` argument.


## Testing without SWUpdate

There are variants of images to try `autoboot` and `tryboot` with no `SWUpdate` on them.


# Quick setup of the development environment

Besides using this repo in your existing [Buildroot][buildroot] installation using the [external mechanism][br2_external], there is also the option to use this [docker-buildroot repo][docker_buildroot] that provides a fast and convenient way to start working right away and keep multiple and independent instances for different targets at the same time.

Those are the instructions for the later case, as the ones to use your existing Buildroot installation are contained in Buildroot's documentation:

## 1. Get the docker container for `Buildroot`:

``` shell
# Get a clone of [docker-buildroot][docker_buildroot], if not already present in your system:
git clone https://github.com/vidalastudillo/docker-buildroot

# Get a clone of this repo to be placed at the folder `externals/pi_swupdate`:
git clone https://github.com/maovidal/buildroot_pi_swupdate externals/pi_swupdate

# Build the Docker image:
docker build -t "advancedclimatesystems/buildroot" .
```

## 2. Setup each [data-only containers][data-only] for the board and mechanism you want to use.

Please note that:

- You can setup all of them and even run them simultaneously (Determined by the amount of resources available on your hardware).

- Each `data-only container` will contain 2 volumes at `/root/buildroot/dl` and `/buildroot_output`.

- `Buildroot` downloads all data to the first volume, the last volume is used as build cache, cross compiler and build results organized in these folders:

    - `./externals/pi_swupdate/`: The `external` folder with the configs, packages, overlays and other related files.
    - `./images/pi_swupdate/`: with the images to be flashed into your device.
    - Also, the `./target/pi_swupdate/` folder is provided to allow checking the building process.

- To tell the `Builroot container` which `data-only container` to use, one helper script is provided (Described in the [next section][building-the-images] in this document).

- `name` will be used on the scripts to refer to this specific build.


### SWUpdate variants


Below you'll find the commands to setup the data-only container for every option available. Those commands will:

    1. Create a data-only container
    2. Set the external mechanism and returns a the value to confirm it has been recorded
    3. Set the default configuration


#### - For the `Pi2` with `SWUpdate` support:

``` shell
docker run -i --name br_output_PiSWU_Pi2 advancedclimatesystems/buildroot /bin/echo "Demo SWUpdate on Pi2."  && \
./externals/pi_swupdate/run_pi2.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_pi2.sh make pi2_defconfig
```

#### - For the `CM4` with `SWUpdate` support:

``` shell
docker run -i --name br_output_PiSWU_CM4 advancedclimatesystems/buildroot /bin/echo "Demo SWUpdate on CM4." && \
./externals/pi_swupdate/run_cm4.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_cm4.sh make cm4_defconfig
```


### No SWUpdate variants


Besides the above, other containers are provided if you just want pre-fabricated definitions to test/develop based on the `tryboot` and `autoboot` mechanisms. The resulting images don't offer `SWUpdate` support.

#### - For the `Pi2` using the `tryboot` mechanism:

``` shell
docker run -i --name br_output_PiSWU_Pi2_tryboot advancedclimatesystems/buildroot /bin/echo "Demo to test tryboot mechanism on Pi2." && \
./externals/pi_swupdate/run_pi2_tryboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_pi2_tryboot.sh make pi2_tryboot_defconfig
```

#### - For the `Pi2` using the `autoboot` mechanism:

``` shell
docker run -i --name br_output_PiSWU_Pi2_autoboot advancedclimatesystems/buildroot /bin/echo "Demo to test autoboot mechanism on Pi2." && \
./externals/pi_swupdate/run_pi2_autoboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_pi2_autoboot.sh make pi2_autoboot_defconfig
```

#### - For the `CM4` using the `tryboot` mechanism:

``` shell
docker run -i --name br_output_PiSWU_CM4_tryboot advancedclimatesystems/buildroot /bin/echo "Demo to test tryboot mechanism on CM4." && \
./externals/pi_swupdate/run_cm4_tryboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_cm4_tryboot.sh make cm4_tryboot_defconfig
```

#### - For the `CM4` using the `autoboot` mechanism:

``` shell
docker run -i --name br_output_PiSWU_CM4_autoboot advancedclimatesystems/buildroot /bin/echo "Demo to test autoboot mechanism on CM4." && \
./externals/pi_swupdate/run_cm4_autoboot.sh make BR2_EXTERNAL=/root/buildroot/externals/pi_swupdate -s printvars VARS='BR2_EXTERNAL_PISWU_CFG_PATH' && \
./externals/pi_swupdate/run_cm4_autoboot.sh make cm4_autoboot_defconfig
```


# Building the images

A small helper script for each option has been provided to ease the use of the containers:

The ones related to the Pi2 and CM4 boards, with SWUpdate support are:

- `./externals/pi_swupdate/run_pi2.sh`
- `./externals/pi_swupdate/run_cm4.sh`

The ones just to test the `tryboot`, `autoboot` mechanisms are:

- `./externals/pi_swupdate/run_pi2_tryboot.sh`
- `./externals/pi_swupdate/run_pi2_autoboot.sh`
- `./externals/pi_swupdate/run_cm4_tryboot.sh`
- `./externals/pi_swupdate/run_cm4_autoboot.sh`

All those scripts are modified versions of the one at `./scripts/run.sh` that use their related `data only` containers providing separated results.

Then you can use usual commands like this in the case of the `CM4` board based on the `autoboot` mechanism:

``` shell
./externals/pi_swupdate/run_cm4_autoboot.sh make menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-rebuild
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make all
```

In case you need to reload the default definitions, here there are the commands for every definition variant (please note that this will ovewrite your changes): 

``` shell
./externals/pi_swupdate/run_pi2.sh make pi2_defconfig
./externals/pi_swupdate/run_pi2_tryboot.sh make pi2_tryboot_defconfig
./externals/pi_swupdate/run_pi2_autoboot.sh make pi2_autoboot_defconfig

./externals/pi_swupdate/run_cm4.sh make cm4_defconfig
./externals/pi_swupdate/run_cm4_tryboot.sh make cm4_tryboot_defconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make cm4_autoboot_defconfig
```


# Using the images

Once an image has been built it will be located in the folder `./images/pi_swupdate/` on your host (ie. `images/pi_swupdate/cm4_autoboot/sdcard.img`)  that can be flashed to the `Pi` following the official Raspberry Pi documentation.

By default, once started, the `Pi` will provide:

- A SSH server. You can login with the default `root` and `hi` as a password. (Please use change those credentials and implement security mechanism according to your needs).
- A web page at http://<your_device_ip>:8080
- A `./check.sh` script that will tell you what mountpoints are available.

You can drop the `SWUpdate image` named `MyProduct.swu` found at `./images/pi_swupdate/<variant>/` to that web page. You will see how the device proceeds with the image update and inform the results.

You may want to use again `./check.sh` to see the new mountpoints available.


## Details about the definitions based on `tryboot`.

The following partitions are created on the device's eMMC:

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


## Details about the definitions based on `autoboot`.

`autoboot.txt` is an undocumented mechanism of Raspberry Pi to boot from a particular partition.

The following partitions are created on the device's eMMC:

- `persistent` located at `mmcblk0p1`: Contains the `autoboot.txt` file that will tell the `Pi` from which parition to boot. The `Pi2` variant also contains a file `bootcode.bin`.
- `boot_a` located at `mmcblk0p2`: Contains the boot information when the set A is the working one.
- `boot_b` located at `mmcblk0p3`: Contains the boot information when the set B is the working one.
- `rootfs_a` located at `mmcblk0p5`: The root filesystem when the set A is the working one.
- `rootfs_b` located at `mmcblk0p6`: The root filesystem when the set B is the working one.

Testing `autoboot` can be done as follows:

1. Starting the pi once energized:
The `Pi` will boot from 2 and use rootfs 5.

2. Issue `set_boot_partition_b.sh` and then `reboot` or `rebootp`
The `Pi` will boot from 3 and use rootfs 6.

3. Issue `set_boot_partition_a.sh` and then `reboot` or `rebootp`
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
[building-the-images]:https://github.com/maovidal/buildroot_pi_swupdate#building-the-images
[autoboot]:https://www.raspberrypi.com/documentation/computers/config_txt.html#autoboot-txt
[tryboot_a_b]:https://www.raspberrypi.com/documentation/computers/config_txt.html#tryboot_a_b
