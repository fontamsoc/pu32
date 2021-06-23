# PU32 Toolchain
[![pu32-toolchain](https://github.com/fontamsoc/pu32-toolchain/actions/workflows/release.yml/badge.svg)](https://github.com/fontamsoc/pu32-toolchain/actions/workflows/release.yml)

## Getting the sources

This repository uses submodules.
We need the --recursive option to fetch the submodules automatically.

	git clone --recursive https://github.com/fontamsoc/pu32-toolchain.git

## Building the sources (Or [download prebuilts](https://github.com/fontamsoc/pu32-toolchain/releases/latest))

	sudo ln -snf /bin/bash /bin/sh
	sudo mkdir -p /opt/pu32-toolchain/
	sudo chown ${UID} /opt/pu32-toolchain/
	PATH="${PATH}:/opt/pu32-toolchain/bin" make -f pu32-toolchain/makefile

Build artifacts get generated in current directory.

## Installing Toolchain

	sudo tar -xf pu32-toolchain.tar.xz -C /opt/

Environment `PATH` must be updated as follow `PATH="${PATH}:/opt/pu32-toolchain/bin"`

## Running Linux in the simulator

	pu32-elf-run --hdd pu32-rootfs.ext2 pu32-vmlinux root=/dev/hda earlyprintk=keep

## Running Linux in GDB

	pu32-elf-gdb pu32-vmlinux -ex 'target sim --hdd pu32-rootfs.ext2' -ex 'load' -ex 'set args root=/dev/hda earlyprintk=keep' -ex 'r'

## Running Linux in an FPGA

Create mbr-style disk image:

	sudo /opt/pu32-toolchain/bin/pu32-mksocimg -k pu32-vmlinux.bin -r pu32-rootfs.ext2 pu32-vmlinux.img

Flash image to sdcard using either `dd if=pu32-vmlinux.img of=/dev/<sdx> bs=1M oflag=sync status=progress` or [BalenaEtcher](https://www.balena.io/etcher).

Flash corresponding FPGA bitstream:
- [xula2lx25](xula2lx25.bit)
- [nexys4ddr / nexysa7](nexys4ddr.bit)

## Reconfigure Linux kernel

	make -f pu32-toolchain/makefile linux-menuconfig

Rebuild the Linux kernel:

	make -f pu32-toolchain/makefile touch-linux pu32-toolchain-build/.linux

## Reconfigure Buildroot

	make -f pu32-toolchain/makefile buildroot-menuconfig

Rebuild buildroot:

	make -f pu32-toolchain/makefile touch-buildroot pu32-toolchain-build/.buildroot
