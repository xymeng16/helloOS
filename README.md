## helloOS

A handcrafted toy kernel inspired by LMOS's [course](https://time.geekbang.org/column/intro/100078401).

### Features
TBD

### Prerequisites
1. gcc
2. nasm
3. grub

### Build
```shell
make kernel # build standalone kernel file
make qemu-grub  # boot the kernel with GRUB in QEMU x86_64 emulator
make qemu-kernel # direct kernel boot in QEMU
```
### Documentation
- How to start from QEMU with GRUB? [[doc]](https://github.com/xymeng16/helloOS/blob/main/docs/using-qemu.md), [[script]](https://github.com/xymeng16/helloOS/blob/main/scripts/mount_image.sh)

### License
TBD
