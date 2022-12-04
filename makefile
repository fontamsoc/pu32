# SPDX-License-Identifier: GPL-2.0-only
# Contributed by William Fonkou Tambe

.PHONY: all linux-menuconfig linux-savedefconfig buildroot-menuconfig touch-binutils touch-gcc touch-linux touch-glibc touch-buildroot touch-fontamsoc-sw clean

NPROC ?= $(shell nproc)

SUDO := $(shell test $$(id -u) -eq 0 || echo -n sudo)

all: pu32-toolchain.tar.xz

pu32-build: pu32
	echo - $@: NPROC == ${NPROC} >&2
	${SUDO} apt install -y build-essential bsdmainutils dosfstools parted wget curl rsync bc cpio unzip texinfo bison flex gawk dejagnu libncurses-dev python-is-python3 libelf-dev zlib1g-dev libgmp-dev libexpat-dev
	${SUDO} mkdir -p /opt/pu32-toolchain
	${SUDO} chown "${USER}" /opt/pu32-toolchain
	mkdir -p pu32-build
	touch $@

pu32-build/binutils: pu32/binutils
	echo - $@: NPROC == ${NPROC} >&2
	if [ ! -e binutils-build ]; then mkdir -p binutils-build && cd binutils-build && \
		${PWD}/pu32/binutils/configure --target=pu32-elf --prefix=/opt/pu32-toolchain --with-expat --disable-nls; fi
	if [ -e binutils-build ]; then cd binutils-build && make -j${NPROC} && make install; fi
	ln -snf ../include /opt/pu32-toolchain/pu32-elf/include
	rm -f $$(find /opt/pu32-toolchain/ | fgrep -e .so -e .la)
	rm -rf /opt/pu32-toolchain/{,pu32-elf/}{var,share}
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

gcc-build: pu32/gcc
	echo - $@: NPROC == ${NPROC} >&2
	if [ ! -e gcc-build ]; then cd pu32/gcc && ./contrib/download_prerequisites && cd - && \
		mkdir -p gcc-build && cd gcc-build && \
		${PWD}/pu32/gcc/configure --target=pu32-elf --prefix=/opt/pu32-toolchain --libexecdir=/opt/pu32-toolchain/lib --without-headers \
			--disable-libssp --disable-multilib --disable-gcov --disable-lto --disable-libatomic --enable-languages=c --disable-nls && \
		make -j${NPROC} && make install; fi
	rm -f $$(find /opt/pu32-toolchain/ | fgrep -e .so -e .la)
	rm -rf /opt/pu32-toolchain/{,pu32-elf/}{var,share}
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

pu32-build/linux: pu32/linux
	echo - $@: NPROC == ${NPROC} >&2
	$(eval KERNEL_BUILD := "${PWD}/linux-build/")
	$(eval KERNEL_SOURCE := "${PWD}/pu32/linux/")
	if [ ! -e ${KERNEL_BUILD} ]; then mkdir -p ${KERNEL_BUILD} && cd ${KERNEL_BUILD} && \
		make -C ${KERNEL_SOURCE} O=${KERNEL_BUILD} ARCH=pu32 defconfig && \
		make ARCH=pu32 CROSS_COMPILE=pu32-elf- V=1 INSTALL_HDR_PATH=/opt/pu32-toolchain headers_install; fi
	if [ -e ${KERNEL_BUILD} ]; then cd ${KERNEL_BUILD} && make ARCH=pu32 CROSS_COMPILE=pu32-elf- V=1 vmlinux.bin && \
		mv vmlinux ../pu32-vmlinux.elf && mv arch/pu32/boot/vmlinux.bin ../pu32-vmlinux.bin; fi
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

pu32-build/glibc: pu32/glibc
	echo - $@: NPROC == ${NPROC} >&2
	if [ ! -e glibc-build ]; then mkdir -p glibc-build && cd glibc-build && \
		CXX=no ${PWD}/pu32/glibc/configure --host=pu32-elf --target=pu32-elf --prefix=/opt/pu32-toolchain/pu32-elf --libexecdir=/opt/pu32-toolchain/pu32-elf/lib \
			--enable-kernel=5.0 --with-headers=/opt/pu32-toolchain/include --disable-profile --enable-static-nss --disable-nscd --disable-werror --without-gd --disable-nls && \
		make update-syscall-lists; fi
	if [ -e glibc-build ]; then cd glibc-build && make -j${NPROC} && make install; fi
	rm -f $$(find /opt/pu32-toolchain/ | fgrep -e .so -e .la)
	rm -f /opt/pu32-toolchain/pu32-elf/bin/{ldd,pldd,sotruss,sprof}
	rm -f /opt/pu32-toolchain/pu32-elf/sbin/{ldconfig,sln}
	rm -rf /opt/pu32-toolchain/{,pu32-elf/}{var,share}
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

pu32-build/gcc: pu32/gcc
	echo - $@: NPROC == ${NPROC} >&2
	if [ ! -e $@ ]; then cd gcc-build && \
		${PWD}/pu32/gcc/configure --target=pu32-elf --prefix=/opt/pu32-toolchain --libexecdir=/opt/pu32-toolchain/lib --without-headers \
			--disable-libssp --disable-multilib --disable-gcov --disable-lto --enable-libatomic --enable-languages=c,c++ --disable-nls; fi
	if [ -e gcc-build ]; then cd gcc-build && make -j${NPROC} && make install; fi
	rm -f $$(find /opt/pu32-toolchain/ | fgrep -e .so -e .la)
	rm -rf /opt/pu32-toolchain/{,pu32-elf/}{var,share}
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

pu32-build/fontamsoc-sw: pu32/fontamsoc-sw
	echo - $@: NPROC == ${NPROC} >&2
	cd pu32/fontamsoc-sw/bios && make clean && make -j${NPROC} install;
	if [ -n "${USEGIT}" ]; then cd /opt/pu32-toolchain/; if [ ! -d .git ]; then git init; fi; git add .; git commit -m "$@"; fi
	touch $@

pu32-build/buildroot: pu32/buildroot
	echo - $@: NPROC == ${NPROC} >&2
	$(eval BUILDROOT_BUILD := "${PWD}/buildroot-build/")
	$(eval BUILDROOT_SOURCE := "${PWD}/pu32/buildroot/")
	if [ ! -e ${BUILDROOT_BUILD} ]; then mkdir -p ${BUILDROOT_BUILD} && cd ${BUILDROOT_BUILD} && \
		make -C ${BUILDROOT_SOURCE} O=${BUILDROOT_BUILD} pu32_defconfig; fi
	if [ -e ${BUILDROOT_BUILD} ]; then cd ${BUILDROOT_BUILD} && make -j${NPROC} V=1 && \
		mv images/rootfs.ext2 ../pu32-rootfs.ext2; fi
	touch $@

pu32-toolchain.tar.xz: \
	pu32-build \
	pu32-build/binutils \
	gcc-build \
	pu32-build/linux \
	pu32-build/glibc \
	pu32-build/gcc \
	pu32-build/fontamsoc-sw \
	pu32-build/buildroot
	echo - $@: NPROC == ${NPROC} >&2
	tar -caf pu32-toolchain.tar.xz --owner=0 --group=0 -C /opt/ --exclude pu32-toolchain/.git pu32-toolchain && \
		ls -lha >&2

pu32-build/linux-headers:
	echo - $@: NPROC == ${NPROC} >&2
	$(eval KERNEL_BUILD := "${PWD}/linux-build/")
	$(eval KERNEL_INSTALL_HDR_PATH := "${PWD}/pu32/linux-headers/")
	mkdir -p ${KERNEL_INSTALL_HDR_PATH}
	[ -e ${KERNEL_BUILD} ] && cd ${KERNEL_BUILD} && \
		make ARCH=pu32 CROSS_COMPILE=pu32-elf- V=1 INSTALL_HDR_PATH=${KERNEL_INSTALL_HDR_PATH} headers_install
	tar -caf ${PWD}/pu32/linux-headers.tar.xz --owner=0 --group=0 -C ${KERNEL_INSTALL_HDR_PATH} include && rm -rf ${KERNEL_INSTALL_HDR_PATH}

linux-menuconfig:
	$(eval KERNEL_BUILD := "${PWD}/linux-build/")
	$(eval KERNEL_SOURCE := "${PWD}/pu32/linux/")
	if [ ! -e ${KERNEL_BUILD} ]; then mkdir -p ${KERNEL_BUILD} && cd ${KERNEL_BUILD} && \
		make -C ${KERNEL_SOURCE} O=${KERNEL_BUILD} ARCH=pu32 defconfig; fi
	if [ -e ${KERNEL_BUILD} ]; then cd ${KERNEL_BUILD} && make ARCH=pu32 CROSS_COMPILE=pu32-elf- menuconfig; fi

linux-savedefconfig:
	$(eval KERNEL_BUILD := "${PWD}/linux-build/")
	$(eval KERNEL_SOURCE := "${PWD}/pu32/linux/")
	if [ ! -e ${KERNEL_BUILD} ]; then mkdir -p ${KERNEL_BUILD} && cd ${KERNEL_BUILD} && \
		make -C ${KERNEL_SOURCE} O=${KERNEL_BUILD} ARCH=pu32 defconfig; fi
	if [ -e ${KERNEL_BUILD} ]; then cd ${KERNEL_BUILD} && make ARCH=pu32 CROSS_COMPILE=pu32-elf- savedefconfig; fi
	cp -a ${KERNEL_BUILD}/defconfig ${KERNEL_SOURCE}/arch/pu32/configs/defconfig

buildroot-menuconfig:
	$(eval BUILDROOT_BUILD := "${PWD}/buildroot-build/")
	$(eval BUILDROOT_SOURCE := "${PWD}/pu32/buildroot/")
	if [ ! -e ${BUILDROOT_BUILD} ]; then mkdir -p ${BUILDROOT_BUILD} && cd ${BUILDROOT_BUILD} && \
		make -C ${BUILDROOT_SOURCE} O=${BUILDROOT_BUILD} pu32_defconfig; fi
	if [ -e ${BUILDROOT_BUILD} ]; then cd ${BUILDROOT_BUILD} && make menuconfig; fi

buildroot-savedefconfig:
	$(eval BUILDROOT_BUILD := "${PWD}/buildroot-build/")
	$(eval BUILDROOT_SOURCE := "${PWD}/pu32/buildroot/")
	if [ ! -e ${BUILDROOT_BUILD} ]; then mkdir -p ${BUILDROOT_BUILD} && cd ${BUILDROOT_BUILD} && \
		make -C ${BUILDROOT_SOURCE} O=${BUILDROOT_BUILD} pu32_defconfig; fi
	if [ -e ${BUILDROOT_BUILD} ]; then cd ${BUILDROOT_BUILD} && make savedefconfig; fi

buildroot-busybox-menuconfig:
	$(eval BUILDROOT_BUILD := "${PWD}/buildroot-build/")
	$(eval BUILDROOT_SOURCE := "${PWD}/pu32/buildroot/")
	if [ ! -e ${BUILDROOT_BUILD} ]; then mkdir -p ${BUILDROOT_BUILD} && cd ${BUILDROOT_BUILD} && \
		make -C ${BUILDROOT_SOURCE} O=${BUILDROOT_BUILD} pu32_defconfig; fi
	if [ -e ${BUILDROOT_BUILD} ]; then cd ${BUILDROOT_BUILD} && make busybox-menuconfig; fi

buildroot-busybox-savedefconfig:
	$(eval BUILDROOT_BUILD := "${PWD}/buildroot-build/")
	$(eval BUILDROOT_SOURCE := "${PWD}/pu32/buildroot/")
	if [ ! -e ${BUILDROOT_BUILD} ]; then mkdir -p ${BUILDROOT_BUILD} && cd ${BUILDROOT_BUILD} && \
		make -C ${BUILDROOT_SOURCE} O=${BUILDROOT_BUILD} pu32_defconfig; fi
	cp -a ${BUILDROOT_BUILD}/build/busybox-*/.config ${BUILDROOT_SOURCE}/package/busybox/busybox.config

touch-binutils:
	touch pu32/binutils
touch-gcc:
	touch pu32/gcc
touch-linux:
	touch pu32/linux
touch-glibc:
	touch pu32/glibc
touch-buildroot:
	touch pu32/buildroot
touch-fontamsoc-sw:
	touch pu32/fontamsoc-sw

clean:
	rm -rf pu32-build binutils-build linux-build glibc-build gcc-build buildroot-build \
		pu32-vmlinux.elf pu32-vmlinux.bin pu32-rootfs.ext2 pu32-toolchain.tar.xz
