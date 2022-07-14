function build_xen() {
    PREFIX=$1
    # Expects the cwd to be Xen repository
    ./configure --prefix=$PREFIX --enable-githttp --disable-pvshim --enable-systemd --enable-ovmf
    echo CONFIG_EXPERT=y > xen/.config
    echo CONFIG_MEM_SHARING=y >> xen/.config
    make -C xen olddefconfig
    make -j$(nproc) dist-xen
    make -j$(nproc) dist-tools
    make -j$(nproc) install-xen
    make -j$(nproc) install-tools
    echo "/usr/local/lib" > /etc/ld.so.conf.d/xen.conf
ldconfig
echo "none /proc/xen xenfs defaults,nofail 0 0" >> /etc/fstab
systemctl enable xen-qemu-dom0-disk-backend.service
systemctl enable xen-init-dom0.service
systemctl enable xenconsoled.service
echo "GRUB_CMDLINE_XEN_DEFAULT=\"hap_1gb=false hap_2mb=false dom0_mem=6096M hpet=legacy-replacement iommu=no-sharept\"" >> /etc/default/grub
update-grub
}

function build_libvmi() {
	PREFIX=$1
	autoreconf -vif
	./configure --disable-kvm --disable-bareflank --disable-file
	make -j$(nproc)
	make -j$(nproc) install
	ldconfig
}

function build_libxdc(){
make -j$(nproc) install
}

function build_capstone(){
mkdir build && cd build
cmake ..
make -j$(nproc)
make -j$(nproc) install
ldconfig
}

function build_afl(){
patch -p1 < ../patches/0001-AFL-Xen-mode.patch
make -j$nproc 
make -j$(nproc) install
}


function build_kfx() {
    PREFIX=$1
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"
    export C_INCLUDE_PATH="$PREFIX/include"
    export CPLUS_INCLUDE_PATH="$PREFIX/include"
    export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig/"
    export LDFLAGS="-L$PREFIX/lib"
    export CFLAGS="-I$PREFIX/include"
    autoreconf -vif
    ./configure 
    make -j$(nproc)
    make -j$(nproc) install
}
