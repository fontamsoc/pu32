# PU32
[![pu32-toolchain](https://github.com/fontamsoc/pu32/actions/workflows/release.yml/badge.svg)](https://github.com/fontamsoc/pu32/actions/workflows/release.yml)

## Build toolchain (or [download prebuilts](https://github.com/fontamsoc/pu32/releases/latest))

	git clone --recursive https://github.com/fontamsoc/pu32.git
	sudo ln -snf /bin/bash /bin/sh
	sudo mkdir -p /opt/pu32-toolchain/
	sudo chown ${UID} /opt/pu32-toolchain/
	PATH="${PATH}:/opt/pu32-toolchain/bin" make -f pu32/makefile

Build artifacts get generated in current directory.

## Install Toolchain

	sudo tar -xf pu32-toolchain.tar.xz -C /opt/
	PATH="${PATH}:/opt/pu32-toolchain/bin"

## Run Linux in binutils-sim

	pu32-elf-run --hdd pu32-rootfs.ext2 pu32-vmlinux root=/dev/hda earlyprintk=keep

Exit the simulator using `poweroff`.

### Target binutils-sim within GDB

	pu32-elf-gdb pu32-vmlinux -ex 'target sim --hdd pu32-rootfs.ext2' -ex 'load' -ex 'set args root=/dev/hda earlyprintk=keep' -ex 'r'

## Run Linux on FPGA

Create mbr-style disk image (or [download prebuilt img](https://github.com/fontamsoc/pu32/releases/latest))

	sudo /opt/pu32-toolchain/bin/pu32-mksocimg -k pu32-vmlinux.bin -r pu32-rootfs.ext2 pu32-vmlinux.img

Flash image to sdcard using either `dd if=pu32-vmlinux.img of=/dev/<sdx> bs=1M oflag=sync status=progress` or [BalenaEtcher](https://www.balena.io/etcher).

Flash corresponding FPGA bitstream:
- [xula2lx25](xula2lx25.bit) ([rebuild](https://github.com/fontamsoc/hw/tree/master/pu32-xula2lx25/ise))
- [nexys4ddr / nexysa7](nexys4ddr.bit) ([rebuild](https://github.com/fontamsoc/hw/tree/master/pu32-nexys4ddr/vivado))

Connect to serial port using 115200n8.

## Run Linux using verilator-sim

Build verilator-sim:

	(cd pu32/fontamsoc-hw/pu32-sim/ && make)

Create mbr-style disk image (or [download prebuilt img](https://github.com/fontamsoc/pu32/releases/latest))

	sudo /opt/pu32-toolchain/bin/pu32-mksocimg -k pu32-vmlinux.bin -r pu32-rootfs.ext2 pu32-vmlinux.img

Convert disk image to verilog .hex file to be loaded through $readmemh():

	hexdump -v -e '/1 "%02x "' pu32-vmlinux.img > pu32/fontamsoc-hw/pu32-sim/img.hex

Run verilator-sim:

	(cd pu32/fontamsoc-hw/pu32-sim/ && ./sim)

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
