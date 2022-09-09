# kfx-sandbox
Docker recipes for kfx
## Install dependencies:
```
sudo apt-get -y install git build-essential libfdt-dev libpixman-1-dev libssl-dev libsdl1.2-dev autoconf libtool xtightvncviewer tightvncserver x11vnc uuid-runtime uuid-dev bridge-utils python3-dev liblzma-dev libc6-dev wget git bcc bin86 gawk iproute2 libcurl4-openssl-dev bzip2 libpci-dev libc6-dev libc6-dev-i386 linux-libc-dev zlib1g-dev libncurses5-dev patch libvncserver-dev libsdl-dev iasl libbz2-dev e2fslibs-dev ocaml libx11-dev bison flex ocaml-findlib xz-utils gettext libyajl-dev libpixman-1-dev libaio-dev libfdt-dev cabextract libglib2.0-dev autoconf automake libtool libjson-c-dev libfuse-dev liblzma-dev autoconf-archive kpartx python3-pip libsystemd-dev cmake snap gcc-multilib nasm binutils bc libunwind-dev ninja-build libcapstone-dev
```
## Install xen and kfx binaries
- grab deb from https://github.com/neelkrish/kfx-sandbox/releases
- Install dependancies : [libnettle](http://archive.ubuntu.com/ubuntu/pool/main/n/nettle/libnettle7_3.5.1+really3.5.1-2ubuntu0.2_amd64.deb) and [libjson-c4](http://security.ubuntu.com/ubuntu/pool/main/j/json-c/libjson-c4_0.13.1+dfsg-7ubuntu0.3_amd64.deb
)
```
- su 
- dpkg -i ubuntu_focal_kfx-bundle-1.0-generic.deb 
- echo "/usr/local/lib" > /etc/ld.so.conf.d/xen.conf
- ldconfig
- echo "none /proc/xen xenfs defaults,nofail 0 0" >> /etc/fstab
- systemctl enable xen-qemu-dom0-disk-backend.service
- systemctl enable xen-init-dom0.service
- systemctl enable xenconsoled.service
- echo "GRUB_CMDLINE_XEN_DEFAULT=\"hap_1gb=false hap_2mb=false dom0_mem=6096M hpet=legacy-replacement iommu=no-sharept\"" >> /etc/default/grub
- update-grub
- reboot
```
