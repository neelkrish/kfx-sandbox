# kfx-sandbox

This repository contains docker recipes for generating deb packages of
[KF/x](https://github.com/intel/kernel-fuzzer-for-xen-project) for installation on
Debian and Ubuntu systems. 

## Compatibility:

This project produces .deb packages suitable for use with:

* Ubuntu 20.04 Focal Fossa
* Ubuntu 18.04 Bionic Beaver
* Debian 11 Bullseye
* Debian 10 Buster

## Installation

The installation process below will guide you through installation of the pre-built
.deb packages from the [releases](https://github.com/neelkrish/kfx-sandbox/releases) page.

### Install dependencies:

The following dependencies are required to use Xen and KF/x and have been tested on
Ubuntu 20.04.

```
sudo apt-get -y install autoconf autoconf-archive automake bc bcc bin86 binutils bison \
    bridge-utils build-essential bzip2 cabextract cmake e2fslibs-dev flex gawk \
    gcc-multilib gettext git iasl iproute2 kpartx libaio-dev libblkid-dev libbz2-dev \
    libc6-dev libc6-dev-i386 libcapstone-dev libcurl4-openssl-dev libdpkg-perl \
    libfdt-dev libfdt1 libffi-dev libfuse-dev libglib2.0-dev libglib2.0-dev-bin \
    libjson-c-dev liblzma-dev libmount-dev libncurses5-dev libpci-dev libpcre16-3 \
    libpcre2-16-0 libpcre2-32-0 libpcre2-dev libpcre2-posix2 libpcre3-dev libpcre32-3 \
    libpcrecpp0v5 libpixman-1-0 libpixman-1-dev libsdl-dev libsdl1.2-dev \
    libselinux1-dev libsepol1-dev libssl-dev libsystemd-dev libtool libunwind-dev \
    libvncserver-dev libx11-dev libyajl-dev libyajl2 linux-libc-dev nasm ninja-build \
    ocaml ocaml-findlib patch pkg-config python3-dev python3-pip snap tightvncserver \
    uuid-dev uuid-runtime wget x11vnc xtightvncviewer xz-utils zlib1g-dev
```
### Install Xen and KF/x binaries

First, grab the latest deb for your platform from [the releases tab](https://github.com/neelkrish/kfx-sandbox/releases)
(if you aren't sure which one to download, run `cat /etc/lsb_release` to show your distro information) and
download it to your working directory.

Then, run (pasting *NOT* recommended in case something goes wrong!) the following
commands:

```
sudo dpkg -i ubuntu_focal_kfx-bundle-1.0-generic.deb 
sudo bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/xen.conf'
sudo ldconfig
sudo bash -c 'echo "none /proc/xen xenfs defaults,nofail 0 0" >> /etc/fstab'
sudo systemctl enable xen-qemu-dom0-disk-backend.service
sudo systemctl enable xen-init-dom0.service
sudo systemctl enable xenconsoled.service
sudo bash -c 'echo "GRUB_CMDLINE_XEN_DEFAULT=\"hap_1gb=false hap_2mb=false dom0_mem=6096M hpet=legacy-replacement iommu=no-sharept\"" >> /etc/default/grub'
sudo update-grub
```

You should see a message like the following:

```
WARNING: GRUB_DEFAULT changed to boot into Xen by default!
    Edit /etc/default/grub.d/xen.cfg to avoid this warning.
```

If you see this, you can go ahead and `sudo reboot now`. If you don't, you have two
options:

1. If you have physical access to the machine at boot, just select Ubuntu with Xen at the Grub menu.
2. If you do *not* have physical access to the machine, see [this answer](https://askubuntu.com/a/110738)
   to learn how to set Xen as the default boot entry, then reboot.

After rebooting, confirm that you have booted into Xen by running:

```
xen-detect
```

You should see:

```
Running in PV context on Xen V4.16.
```
