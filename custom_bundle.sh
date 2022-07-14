#!/bin/bash

# Import utils
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/build_utils.sh

function help() {
    echo "Usage: "
    echo "$0 [kfx-sandbox tree] [patch directory]"
    echo
    echo "Patch dir is expected to contain xen/"
    echo "Each of them containts patch files for appropriate subsystems"
}

if [ $# -ne "2" ]; then
    help
    exit 1
fi


SANDBOX_DIR=$1

# Don't clobber local repository
cp -ra $SANDBOX_DIR /repo-local
SANDBOX_DIR=/repo-local

PATCH_DIR=$2
XEN_DIR=$SANDBOX_DIR/kernel-fuzzer-for-xen-project/xen
KFX_DIR=$SANDBOX_DIR/kernel-fuzzer-for-xen-project
set -e
function update_repo(){
	pushd $KFX_DIR
	git submodule update --init
	ln -s /usr/include/x86_64-linux-gnu/pci /usr/include/pci
	popd
}

function setup_repository () {
    pushd $XEN_DIR
    # Configure Xen. 
    echo "[+] Configuring Xen"
       ./configure --prefix=/usr --enable-githttp --disable-pvshim
	popd
}
echo "[+] Setting up repository"
setup_repository


INSTALL_PATH=/build/usr
mkdir -p $INSTALL_PATH

echo "[+] Building Xen"
pushd $XEN_DIR
build_xen /usr
mv dist/install /dist-xen
popd

echo "[+] Building capstone"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project/capstone
build_capstone $INSTALL_PATH
popd

echo "[+] Building LibVMI"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project/libvmi
build_libvmi $INSTALL_PATH
popd

echo "[+] Building dwarf2json"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project/dwarf2json
/usr/local/go/bin/go build
mkdir -p /build/dwarf2json/
mv dwarf2json /build/dwarf2json/
popd

echo "[+] Building libxdc"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project/libxdc
build_libxdc $INSTALL_PATH
popd

echo "[+] Building AFL"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project/AFL
patch -p1 < ../patches/0001-AFL-Xen-mode.patch
build_afl $INSTALL_PATH
popd


echo "[+] Building KFX"
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project
build_kfx $INSTALL_PATH
popd


echo "[+] Packaging KFX"
mkdir -p /out
pushd $SANDBOX_DIR/kernel-fuzzer-for-xen-project
sh ./package/mkdeb
popd
