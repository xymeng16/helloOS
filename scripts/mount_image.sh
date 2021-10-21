#!/bin/bash

#set -x # enable ECHO

IMAGE_NAME=helloOS.img
MOUNT_POINT="$(pwd)/image/"

function unmount_all() {
  if [[ "$(grep 'helloOS' /proc/mounts)" ]]; then
  echo "$IMAGE_NAME have already been mounted to $MOUNT_POINT..."
    sudo umount $MOUNT_POINT
  fi

  LOOP_DEVICE_NAME=$(losetup -a | grep $IMAGE_NAME | sed 's/|/ /' | awk '{print $1}' | cut -d':' -f 1)
  if [ "$LOOP_DEVICE_NAME" ]; then
    echo "$IMAGE_NAME is mounted to $LOOP_DEVICE_NAME, unmount it now..."
    sudo losetup -d $LOOP_DEVICE_NAME
  fi
}

function mount_as_loop() {
  LOOP_DEVICE_NAME=$(losetup -f)
  sudo losetup --partscan $LOOP_DEVICE_NAME $IMAGE_NAME
  LOOP_PARTITION_NAME="${LOOP_DEVICE_NAME}p1"
}

function mount_as_drive() {
  if [ -d $MOUNT_POINT ]; then
    sudo rm -rf $MOUNT_POINT
    mkdir $MOUNT_POINT
  fi
  sudo mount $LOOP_PARTITION_NAME $MOUNT_POINT
  echo "$IMAGE_NAME (mapped to $LOOP_DEVICE_NAME:$LOOP_PARTITION_NAME) has successfully been mounted to $MOUNT_POINT"
}

if [[ "$(grep 'helloOS' /proc/mounts)" ]]; then
  echo "$IMAGE_NAME have already been mounted to $MOUNT_POINT..."
else
  unmount_all

  if [ -f "$IMAGE_NAME" ]; then
    echo "$IMAGE_NAME exists, image creation skipped... (suppose GRUB is installed in the image)"
    mount_as_loop
    mount_as_drive
  else
    echo "$IMAGE_NAME does not exist, create the image (default size: 512M)."
    dd if=/dev/zero of=$IMAGE_NAME bs=1024 count=524288
    printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk $IMAGE_NAME
    mount_as_loop
    sudo mkfs.ext4 $LOOP_PARTITION_NAME
    mount_as_drive
    sudo grub-install --root-directory=$MOUNT_POINT --no-floppy --target=i386-pc $LOOP_DEVICE_NAME
  fi

  echo "Configuring GRUB..."

  sudo grub-editenv $MOUNT_POINT/boot/grub/grubenv set prefix=\(hd0,msdos1\)/boot/grub

  printf "menuentry 'helloOS' {\n set root='hd0,msdos1' \n multiboot2 /helloOS.bin\n boot\n}\n" | sudo tee $MOUNT_POINT/boot/grub/grub.cfg
fi

echo "Copy the latest kernel to the image..."
sudo cp helloOS.bin $MOUNT_POINT

# remount to avoid inconsistency
sudo umount $MOUNT_POINT
sudo mount $LOOP_PARTITION_NAME $MOUNT_POINT

echo "Enjoy OS hacking."