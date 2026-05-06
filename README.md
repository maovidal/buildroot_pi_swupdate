# Description

The purpose of this repository is to provide templates that implement a
mechanism to update a device that allows it to return to a previous working
state in case the update fails with these considerations:

- The device provides a webpage at `http://<your_device_ip>:8080` to receive a new image.
- The device uses two redundant sets of partitions, named A and B. Each set has a `boot` and a `rootfs`.
- The supported devices are `Raspberry Pi 2B` and `Raspberry Pi Compute Module 4`.

When the device is running from one of those sets of partitions and an update
is requested, the device will:

1. Write the set of partitions that is not in use with the image received.
2. Once completed, the device will restart to test the updated set of partitions.
3. If it is able to boot, it will update a file that will tell it to use that set of partitions for the next boots.

In case that the process is interrupted at any point before the last step the
device will keep using the set of partitions that was not updated.

**⚠️ This is a continuous work in progress ⚠️**

This repo also serves as a starting point to test related improvements over
its basic purpose. Currently the following is due to be solved:

- Investigate how to prevent and deal with possible corruptions of the filesystem.
- The current `web-app` at `/board/raspberrypi/generic/overlay_swupdate/var/www/swupdate/`
  is a copy of the one shipped with `SWUpdate 2021.04`. Investigate why a newer version
  can't be used.

**For the `CM4` it requires EEPROM updated to `pieeprom-2022-10-18.bin` at least.**

**🛠 Pull requests are welcome! 🛠**


## Under the hood

[SWUpdate][swupdate] deploys a web page to receive the new image provided by
the user and writes it to the device.

The reboot mechanism is provided by a custom `rebootp` command implemented
originally by the [PINN project][PINN_rebootp] because the original `reboot`
command does not inject both the partition number and tryboot arguments
required to switch partitions.

An init script called `S80swupdate` is in charge of testing if the device is
starting from the expected boot partition after an update has been performed,
making the change permanent in that case.

The [`autoboot` mechanism][autoboot] and its option [tryboot_a_b][tryboot_a_b]
are implemented to let the device identify the current working boot partition
and the one to test when requested by a `rebootp` using the `tryboot` argument.


## Testing without SWUpdate

There are variants of images to try `autoboot` and `tryboot` with no
`SWUpdate` on them.


# Quick setup

Besides using this repo in your existing [Buildroot][buildroot] installation
using the [external mechanism][br2_external], there is also the option to use
this [docker-buildroot repo][docker_buildroot] that provides a fast and
convenient way to start working right away and keep multiple and independent
instances for different targets at the same time.

1. Clone [docker-buildroot][docker_buildroot], if not already present:

```shell
git clone https://github.com/vidalastudillo/docker-buildroot
cd docker-buildroot
```

2. Set up the Buildroot source:

```shell
./scripts/bootstrap.sh
```

See [`BUILDROOT_VERSION`](https://github.com/vidalastudillo/docker-buildroot#buildroot-source-buildroot_version) in `docker-buildroot` for the configured fork and branch, or to use a different one.

3. Clone this repo into `externals/pi_swupdate`:

```shell
git clone https://github.com/maovidal/buildroot_pi_swupdate externals/pi_swupdate
```

4. Build the shared Docker image (once):

```shell
docker buildx build -t va_buildroot .
```

These are the relevant folders on your host:

- `externals/pi_swupdate/`: the external tree with configs, packages, overlays and related files.
- `images/pi_swupdate/`: build outputs organized by target variant.
- `target/pi_swupdate/`: unpacked root filesystem for inspection.


# Building the images

Run scripts are provided for each target variant. They must always be called
from the root of the `docker-buildroot` project.

### SWUpdate variants

```shell
# Raspberry Pi 2B
./externals/pi_swupdate/run_pi2.sh make pi2_defconfig
./externals/pi_swupdate/run_pi2.sh make all

# Raspberry Pi Compute Module 4
./externals/pi_swupdate/run_cm4.sh make cm4_defconfig
./externals/pi_swupdate/run_cm4.sh make all
```

### No-SWUpdate variants (tryboot / autoboot testing)

```shell
./externals/pi_swupdate/run_pi2_tryboot.sh make pi2_tryboot_defconfig
./externals/pi_swupdate/run_pi2_autoboot.sh make pi2_autoboot_defconfig

./externals/pi_swupdate/run_cm4_tryboot.sh make cm4_tryboot_defconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make cm4_autoboot_defconfig
```

### Common commands

```shell
./externals/pi_swupdate/run_cm4_autoboot.sh make menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-rebuild
./externals/pi_swupdate/run_cm4_autoboot.sh make linux-menuconfig
./externals/pi_swupdate/run_cm4_autoboot.sh make all
```


# Using the images

Once built, images are located in `./images/pi_swupdate/<variant>/` on your
host (e.g. `images/pi_swupdate/cm4_autoboot/sdcard.img`) and can be flashed
following the official Raspberry Pi documentation.

By default, once started, the device will provide:

- A SSH server. Login with `root` / password `hi`.
- A web page at `http://<your_device_ip>:8080`
- A `./check.sh` script that reports the current active mountpoints.

Drop the `SWUpdate image` named `MyProduct.swu` found at
`./images/pi_swupdate/<variant>/` to that web page to trigger an update.


## Details about the `tryboot` definitions

Partitions created on the device's eMMC:

- `boot_a` at `mmcblk0p1`: boot files when set A is active.
- `boot_b` at `mmcblk0p2`: boot files when set B is active.
- `persistent` at `mmcblk0p3`: VFAT partition that survives updates.
- `rootfs_a` at `mmcblk0p5`: root filesystem for set A.
- `rootfs_b` at `mmcblk0p6`: root filesystem for set B.


## Details about the `autoboot` definitions

Partitions created on the device's eMMC:

- `persistent` at `mmcblk0p1`: contains `autoboot.txt`. The Pi2 variant also contains `bootcode.bin`.
- `boot_a` at `mmcblk0p2`: boot files when set A is active.
- `boot_b` at `mmcblk0p3`: boot files when set B is active.
- `rootfs_a` at `mmcblk0p5`: root filesystem for set A.
- `rootfs_b` at `mmcblk0p6`: root filesystem for set B.


# License

This software is licensed under MIT License.

&copy; 2022 Mauricio Vidal.

[docker_buildroot]: https://github.com/vidalastudillo/docker-buildroot
[buildroot]: https://buildroot.org/
[br2_external]: https://buildroot.org/downloads/manual/manual.html#outside-br-custom
[swupdate]: https://sbabic.github.io/swupdate/swupdate.html
[PINN_rebootp]: https://github.com/procount/pinn/tree/master/buildroot/package/rebootp
[autoboot]: https://www.raspberrypi.com/documentation/computers/config_txt.html#autoboot-txt
[tryboot_a_b]: https://www.raspberrypi.com/documentation/computers/config_txt.html#tryboot_a_b
