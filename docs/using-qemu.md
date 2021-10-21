# How to start from QEMU with GRUB
## Idea  
Create a disk image and setup it as a loop device so that it could be mounted as a regular disk. Then we can install grub into the disk image and copy our kernel inside it. Some required configurations will be mentioned later.
## Prerequisite (install using the package manager of your Linux distro)
- qemu
- grub
## TL;DR  
For those who are not interested in following technical details, just use the following commands to test your toy kernel in QEMU (booted with GRUB)
```shell
make clean
make qemu-grub
```
## Create an image
```shell
dd if=/dev/zero of=helloOS.img bs=1024 count=524288
```
### Create a new dos partition table, and then create a new primary partition in this image (for the detailed usage of `fdisk`, please refer to its internal documents)
```shell
printf "o\nn\np\n1\n\n\nw\n" | fdisk helloOS.img
```
### Setup it as a loop device (more details of mknod can be found using `man mknod`, `man losetup` and [here](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/devices.txt))
```shell
LOOP_DEVICE=$(losetup -f)
sudo losetup --partscan $(losetup -f) helloOS.img
```
### Now check your /dev/ folder, some file named "loopxp1" should appear here. This file should be the first (and maybe the only) partition of /dev/loopx (also helloOS.img).
### If everything goes well, now let's make a file system for above partition and mount to somewhere you like.
```shell
sudo mkfs.ext4 "${LOOP_DEVICE}p1"
mkdir boot
sudo mount "${LOOP_DEVICE}p1" ./boot
```
### Install `grub` to above mount point
```shell
sudo grub-install --root-directory=$(pwd)/boot --no-floppy --target=i386-pc ${LOOP_DEVICE}
```
### Successful install will trigger following outputs:
```
Installing for i386-pc platform.
Installation finished. No error reported.
```
## Test it in qemu!
```shell
qemu-system-x86_64 -drive format=raw,file=helloOS.img
```
### And the GRUB command prompt will appear in the QEMU window, like
```shell
grub>
```
## Try our kernel with this GRUB image.  
###Now we need to copy the kernel file (mine is named helloOS.bin) to the ./boot directory, remake the QEMU image and start QEMU again.
```shell
sudo cp helloOS.bin boot/
qemu-system-x86_64 -drive format=raw,file=helloOS.img
```
### Once QEMU starts and the GRUB command prompt shows, please type the following commands:
```shell
grub> ls
(hd0)(hd0,msdos1)(fd0)
grub> root=(hd0,msdos1)
grub> multiboot2 /helloOS.bin
grub> boot
```
### If successful, you will see "Hello, OS!" on the top of QEMU screen. Then let's add a menu entry to our GRUB image so that we don't need to type above commands on each time of boot.
## Add a meun entry to GRUB.
```shell
sudo grub-editenv boot/boot/grub/grubenv set prefix=\(hd0,msdos1\)/boot/grub
```
### Above command tells GRUB the root partition that contains the information for booting the system. In our environment, it should be "(hd0,msdos1)/boot/grub".  
### Then, create a grub.cfg file to the boot/boot/grub/ directory. It should contain the following lines:
```
menuentry 'helloOS' {
     set root='hd0,msdos1' 
     multiboot2 /helloOS.bin
     boot
}
```
### Now, remake the QEMU image and run QEMU again:
```shell
qemu-system-x86_64 -drive format=raw,file=helloOS.img
```
### The meun entry named helloOS should appear on the screen!