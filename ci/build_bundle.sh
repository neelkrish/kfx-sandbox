#!/bin/bash

# Import utils
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/build_utils.sh


mc stat cache/debs/kfx-bundle-1.deb
if [ $? -eq 0 ]; then
    echo "Package already exists. Skipping..."
    exit 0
fi

set -e

# Usage of /build as root is required by KFX's mkdeb script
INSTALL_PATH=/build/usr
mkdir -p $INSTALL_PATH

# Build Xen
pushd kernel-fuzzer-for-xen-project/xen
# We use /usr because LibVMI wants to see
# Xen headers. 
build_xen /usr
mv dist/install /dist-xen
popd

# Build LibVMI
pushd kernel-fuzzer-for-xen-project/libvmi
build_libvmi $INSTALL_PATH
popd

# Build Capstone
pushd kernel-fuzzer-for-xen-project/capstone
build_capstone $INSTALL_PATH
popd

# Build libxdc
pushd kernel-fuzzer-for-xen-project/libxdc
build_libxdc $INSTALL_PATH
popd

# Build AFL
pushd kernel-fuzzer-for-xen-project/AFL
build_afl $INSTALL_PATH
popd

# Build kfx
pushd kernel-fuzzer-for-xen-project
build_kfx $INSTALL_PATH
popd

# Build dwarf2json
pushd drakvuf/dwarf2json
/usr/local/go/bin/go build
mkdir -p /build/dwarf2json/
mv dwarf2json /build/dwarf2json/
popd

# Package kernel-fuzzer-for-xen-project
pushd kernel-fuzzer-for-xen-project
mkdir /out
sh ./package/mkdeb
popd

mc cp /out/kfx-bundle*.deb "cache/debs/kfx-bundle-1.deb"

