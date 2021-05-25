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
