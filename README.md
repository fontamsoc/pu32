# PU32
[![pu32-toolchain](https://github.com/fontamsoc/pu32/actions/workflows/release.yml/badge.svg)](https://github.com/fontamsoc/pu32/actions/workflows/release.yml)

	git clone --recursive https://github.com/fontamsoc/pu32.git

## Build toolchain (or [download prebuilt](https://github.com/fontamsoc/pu32/releases/latest/download/pu32-toolchain.tar.xz))

	sudo ln -snf /bin/bash /bin/sh
	sudo mkdir -p /opt/pu32-toolchain/
	sudo chown ${UID} /opt/pu32-toolchain/
	PATH="${PATH}:/opt/pu32-toolchain/bin" make -f pu32/makefile

Build artifacts get generated in current directory.

## Install Toolchain

	sudo tar -xf pu32-toolchain.tar.xz -C /opt/
	PATH="${PATH}:/opt/pu32-toolchain/bin"

## Run Linux in binutils-sim

	pu32-elf-run --hdd pu32-rootfs.ext2 pu32-vmlinux.elf root=/dev/hda earlyprintk=keep

Exit the simulator using `poweroff`.

### Target binutils-sim within GDB

	pu32-elf-gdb pu32-vmlinux.elf -ex 'target sim --hdd pu32-rootfs.ext2' -ex 'load' -ex 'set args root=/dev/hda earlyprintk=keep' -ex 'r'

## Run Linux on FPGA

Create mbr-style disk image (or [download prebuilt](https://github.com/fontamsoc/pu32/releases/latest/download/pu32.img.xz))

	pu32-mksocimg -k pu32-vmlinux.bin -r pu32-rootfs.ext2 pu32.img

Flash image to sdcard using either `dd if=pu32.img of=/dev/<sdx> bs=1M oflag=sync status=progress` or [BalenaEtcher](https://www.balena.io/etcher).

Flash corresponding FPGA bitstream:
- [nexys4ddr / nexysa7](nexys4ddr.bit) ([rebuild](https://github.com/fontamsoc/hw/tree/main/pu32-nexys4ddr/vivado2020))
- [nexysvideo](nexysvideo.bit) ([rebuild](https://github.com/fontamsoc/hw/tree/main/pu32-nexysvideo/vivado2020))
- [genesys2](genesys2.bit) ([rebuild](https://github.com/fontamsoc/hw/tree/main/pu32-genesys2/vivado2020))
- [orangecrab0225](orangecrab0225.dfu) ([rebuild](https://github.com/fontamsoc/hw/tree/main/pu32-orangecrab0225/yosys))
- [orangecrab0285](orangecrab0285.dfu) ([rebuild](https://github.com/fontamsoc/hw/tree/main/pu32-orangecrab0285/yosys))

Connect to serial port using 115200n8.

## Run Linux using verilator sim

Create mbr-style disk image (or [download prebuilt](https://github.com/fontamsoc/pu32/releases/latest/download/pu32.img.xz))

	pu32-mksocimg -k pu32-vmlinux.bin -r pu32-rootfs.ext2 pu32.img

Convert disk image to verilog .hex file to be loaded through $readmemh():

	hexdump -v -e '/1 "%02x "' pu32.img > pu32/fontamsoc-hw/pu32-sim/pu32.img.hex

Run verilator sim:

	(cd pu32/fontamsoc-hw/pu32-sim/ && make run)

Terminate verilator-sim using ctrl+c.

## Reconfigure Linux kernel

	make -f pu32/makefile linux-menuconfig

Optionally save kernel configuration to `linux/arch/pu32/configs/defconfig`:

	make -f pu32/makefile linux-savedefconfig

Rebuild the Linux kernel:

	make -f pu32/makefile touch-linux pu32-build/linux

## Reconfigure Buildroot

	make -f pu32/makefile buildroot-menuconfig

Optionally save Buildroot configuration to `buildroot/configs/pu32_defconfig`:

	make -f pu32/makefile buildroot-savedefconfig

Reconfigure BusyBox:

	make -f pu32/makefile buildroot-busybox-menuconfig

Optionally save BusyBox configuration to `buildroot/package/busybox/busybox.config`:

	make -f pu32/makefile buildroot-busybox-savedefconfig

Rebuild Buildroot:

	make -f pu32/makefile touch-buildroot pu32-build/buildroot
