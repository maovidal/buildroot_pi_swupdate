# Description

The purpose of this repository is to generate an image tested on `buildroot 2022.08.1` that can be flashed on the internal eMMC of the `Raspberry Pi Compute Module 4` providing a mechanism to update its filesystem via a web page.

That mechanism considers this:

- The running device provides a web page that allows it to receive an image update.
- If the image update does not succeed, the device will keep its current (working) image.

To achieve that a redundant approach is implemented with two sets of partitions named A and B. When the device is requested to perform an image update, it will prepare the non working set with the new data and it will restart once the update is completed to use it. If succeded, it will keep track of it to use it across restarts. Otherwise, on a failed update, the device will keep using the set that worked before the update.

[U-Boot][uboot] is needed here to being in charge to decide which set to use.

[SWUpdate][swupdate] on the other hand, is in charge to provide the image update and the webpage interface.

The following partitions will be created on the device's eMMC:

- persistent: a small non volatile VFAT partition to keep the results of the state / transition of the image and other information that should be kept among restarts.
- boota_env: An image that contains instructions for U-Boot when the set A is the working one.
- bootb_env: An image that contains instructions for U-Boot when the set B is the working one.
- boota: An image that contains the boot information when the set A is the working one.
- bootb: An image that contains the boot information when the set B is the working one.
- rootfsa: An image with the root filesystem when the set A is the working one.
- rootfsb: An image with the root filesystem when the set B is the working one.


# Quick setup

Besides using this repo in your existing Buildroot installation using the [external mechanism][br2_external], there is also the option to use this [docker-buildroot repo][docker_buildroot] that provides a fast and convenient way to start working right away and keep multiple and independent instances for different targets at the same time.

Those are the instructions for the later case, as the ones to use your existing Buildroot installation are contained in Buildroot's documentation:

1. Get a clone of [docker-buildroot][docker_buildroot], if not already present in your system:

``` shell
git clone https://github.com/vidalastudillo/docker-buildroot
```

2. Get a clone of this repo to be placed at the folder `externals/uboot_swupdate`:

``` shell
git clone https://github.com/maovidal/buildroot_uboot_swupdate externals/uboot_swupdate
```

3. Build the Docker image, if not already present in your system:

``` shell
docker build -t "advancedclimatesystems/buildroot" .
```

4. Create a [data-only container][data-only]. The name will be used on the scripts to refer to this spacific build:

``` shell
docker run -i --name br_output_US_CM4 advancedclimatesystems/buildroot /bin/echo "Data only for U-Boot SWUpdate on CM4."
```

This container has 2 volumes at `/root/buildroot/dl` and `/buildroot_output`.
Buildroot downloads all data to the first volume, the last volume is used as build cache, cross compiler and build results.

5. Setup the new external folder and load the default configuration:

``` shell
./externals/uboot_swupdate/run_cm4.sh make BR2_EXTERNAL=/root/buildroot/externals/uboot_swupdate menuconfig
./externals/uboot_swupdate/run_cm4.sh make cm4_defconfig
```

These are the two relevant folders on your host:

- `externals/uboot_swupdate/cm4`: the new external folder with the configs and other related files for this CM4 board.
- `images/uboot_swupdate/cm4`: with your valuable results.

Also, the `target/uboot_swupdate/cm4` folder is provided just to ease checking the building process.


# Usage

A small script has been provided to make using the container a little easier.
It's located at the folder `./externals/uboot_swupdate/run_cm4.sh` which is a modified version of the one at `./scripts/run.sh`.

This modified script uses the `data only` container defined exclusively for this `U-Boot SWUpdate on CM4` and produces the output separated in the `uboot_swupdate/cm4` folders.

Then you can use usual commands like this:

``` shell
./externals/uboot_swupdate/run_cm4.sh make menuconfig
./externals/uboot_swupdate/run_cm4.sh make linux-rebuild
./externals/uboot_swupdate/run_cm4.sh make linux-menuconfig
./externals/uboot_swupdate/run_cm4.sh make all
```


# License

This software is licensed under MIT License.

&copy; 2022 Mauricio Vidal.

[docker_buildroot]:https://github.com/vidalastudillo/docker-buildroot
[original_docker_buildroot_repo]:https://github.com/AdvancedClimateSystems/docker-buildroot
[buildroot]:http://buildroot.uclibc.org/
[data-only]:https://docs.docker.com/userguide/dockervolumes/
[br2_external]:http://buildroot.uclibc.org/downloads/manual/manual.html#outside-br-custom
[uboot]:https://u-boot.readthedocs.io/en/latest/
[swupdate]:https://sbabic.github.io/swupdate/swupdate.html
