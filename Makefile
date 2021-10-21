MAKEFLAGS = -sR
MKDIR = mkdir
RMDIR = rmdir
CP = cp
CD = cd
DD = dd
RM = rm

ASM		= nasm
CC		= gcc
LD		= ld
OBJCOPY	= objcopy

ASMBFLAGS	= -f elf -w-orphan-labels
CFLAGS		= -c -Os -std=c99 -m32 -Wall -Wshadow -W -Wconversion -Wno-sign-conversion  -fno-stack-protector -fomit-frame-pointer -fno-builtin -fno-common  -ffreestanding  -Wno-unused-parameter -Wunused-variable
LDFLAGS		= -s -static -T helloOS.lds -n -Map helloOS.map
OJCYFLAGS	= -S -O binary

HELLOOS_OBJS :=
HELLOOS_OBJS += entry.o kmain.o vgastr.o

HELLOOS_ELF = helloOS.elf
HELLOOS_BIN = helloOS.bin

HELLOOS_IMG = helloOS.img
HELLOOS_QEMUIMG = helloOS-qemu.img

.PHONY : build clean all link bin update_img qemu unmount

all: build link bin

clean: unmount
	$(RM) -f *.o *.bin *.elf *.map *.img

build: $(HELLOOS_OBJS)

link: $(HELLOOS_ELF)

$(HELLOOS_ELF): $(HELLOOS_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(HELLOOS_OBJS)

bin: $(HELLOOS_BIN)

$(HELLOOS_BIN): $(HELLOOS_ELF)
	$(OBJCOPY) $(OJCYFLAGS) $< $@

%.o : %.asm
	$(ASM) $(ASMBFLAGS) -o $@ $<

%.o : %.c
	$(CC) $(CFLAGS) -o $@ $<

update_img: $(HELOOOS_QEMUIMG)

$(HELLOOS_QEMUIMG): $(HELLOOS_BIN)
	scripts/mount_image.sh

qemu-grub: $(HELLOOS_QEMUIMG)
	qemu-system-x86_64 -drive format=raw,file=helloOS.img

qemu-kernel: $(HELLOOS_BIN)
	qemu-system-x86_64 -kernel $(HELLOOS_BIN)

unmount:
	sudo scripts/unmount_image.sh