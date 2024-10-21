# SPDX-License-Identifier: GPL-2.0
obj-m := panic-test.o

all:
	make LLVM=1 -C /lib/modules/$(shell uname -r)/build M=$(PWD)

gcc:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD)

clean:
	make LLVM=1 -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

help:
	@echo "make"
	@echo "       Build the module using Clang"
	@echo "make gcc"
	@echo "       Build the module using GCC"
	@echo "make clean"
	@echo "       Remove generated files"