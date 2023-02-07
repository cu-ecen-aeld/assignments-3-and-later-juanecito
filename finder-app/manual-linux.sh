#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here

    # deep clean kernel tree
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper

    # Configure for virt -> QEMU
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig

    # Build kernel image
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all

    # Build kernel modules
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules

    # Build dtbs
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/arm64/boot/Image ${OUTDIR}/Image


echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir ${OUTDIR}/rootfs

cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/sbin usr/lib
mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -C ${OUTDIR}/busybox
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -C ${OUTDIR}/busybox install 

cd ${OUTDIR}/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

SYSROOT=`aarch64-none-linux-gnu-gcc -print-sysroot`

# TODO: Add library dependencies to rootfs
cp -L ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/ld-linux-aarch64.so
cp -L ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/

cp -L ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp -L ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/libm.so
cp -L ${SYSROOT}/lib64/libresolv-2.31.so ${OUTDIR}/rootfs/lib64/
cp -L ${SYSROOT}/lib64/libresolv-2.31.so ${OUTDIR}/rootfs/lib64/libresolv.so.2
cp -L ${SYSROOT}/lib64/libresolv-2.31.so ${OUTDIR}/rootfs/lib64/libresolv.so
cp -L ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/
cp -L ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/libc.so

# TODO: Make device nodes

sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/console c 5 1

# TODO: Clean and build the writer utility

make CROSS_COMPILE=${CROSS_COMPILE} -C ${FINDER_APP_DIR} clean
make CROSS_COMPILE=${CROSS_COMPILE} -C ${FINDER_APP_DIR}


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

# cp -H ${FINDER_APP_DIR} ${OUTDIR}/rootfs/home
find ${FINDER_APP_DIR} -type f -execdir cp "{}" ${OUTDIR}/rootfs/home ";"
cp -Lr ${FINDER_APP_DIR}/conf .
ln -s ../conf home/conf

# TODO: Chown the root directory

sudo chown -R root:root ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
rm -f ${OUTDIR}/initramfs.cpio
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

cd ${OUTDIR}
# TODO: Create initramfs.cpio.gz
rm -f initramfs.cpio.gz
gzip -f initramfs.cpio
