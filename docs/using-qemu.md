# How to start from QEMU
0. Idea  
Create a disk image and setup it as a loop device so that it could be mounted as a regular disk. Then we can install grub into the disk image and copy our kernel inside it. Some required configurations will be mentioned later.
1. TL;DR
2. Prerequisite (install using the package manager of your Linux distro)
- qemu
- grub
3. Create an image
```shell
dd if=/dev/zero of=helloOS.img bs=1024 count=524288
```
4. Setup it as a loop device (more details of mknod can be found using "man mknod", "man losetup" and [here](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/devices.txt))
```shell
sudo mknod /dev/loop8 b 7 200 
sudo losetup /dev/loop8 helloOS.img
```
5. Create a new dos partition table, and then create a new primary partition for /dev/loop8 (for the detailed usage of fdisk, please refer to its internal documents)
```shell
sudo fdisk /dev/loop8
```
6. Notify kernel the modification of the partition
```shell
sudo kpartx -av /dev/loop8
```
7. Now check your /dev/mapper folder, some file named "loop8p1" should appear here. This file should be the first (and maybe the only) partition of /dev/loop8 (also helloOS.img).
8. If everything goes well, now let's make a file system for above partition and mount to somewhere you like.
```shell
sudo mkfs.ext4 /dev/mapper/loop8p1
mkdir boot
sudo mount /dev/mapper/loop8p1 ./boot
```
9. Install grub to above mount point
```shell
sudo grub-install --root-directory=$(pwd)/boot --no-floppy --target=i386-pc /dev/loop8
```
Successful install will trigger following output:
```
Installing for i386-pc platform.
Installation finished. No error reported.
```
10. Now convert the image to the QEMU image format
```shell
qemu-img convert -O qcow2 helloOS.img helloOS-qemu.img
```
11. Run it in qemu!
```shell
qemu-system-x86_64 -hda ./helloOS-qemu.img
```
And the GRUB command prompt will appear in the QEMU window, like
```shell
grub>
```
12. Try out kernel with this GRUB image.  
Now we need to copy the kernel file (mine is named helloOS.bin) to the ./boot directory, remake the QEMU image and start QEMU again.
```shell
sudo cp helloOS.bin boot/
qemu-img convert -O qcow2 helloOS.img helloOS-qemu.img
qemu-system-x86_64 -hda ./helloOS-qemu.img
```
Once QEMU starts and the GRUB command prompt shows, please type the following commands:
```shell
grub> ls
(hd0)(hd0,msdos1)(fd0)
grub> root=(hd0,msdos1)
grub> multiboot2 /helloOS.bin
grub> boot
```
If successful, you will see "Hello, OS!" on the top of QEMU screen. Then let's add a menu entry to our GRUB image so that we don't need to type above commands on each time of boot.
13. Add a meun entry to GRUB.
```shell
sudo grub-editenv grubenv set prefix=\(hd0,msdos1\)/boot/grub
```
Above command tells GRUB the root partition that contains the information for booting the system. In our environment, it should be "(hd0,msdos1)/boot/grub".  
Then, create a grub.cfg file to the boot/boot/grub/ directory. It should contain the following lines:
```
menuentry 'helloOS' {
     set root='hd0,msdos1' 
     multiboot2 /HelloOS.bin
     boot
}
```
Now, remake the QEMU image and run QEMU again
```
qemu-img convert -O qcow2 helloOS.img helloOS-qemu.img
qemu-system-x86_64 -hda ./helloOS-qemu.img
```
The meun entry named helloOS should appear on the screen!