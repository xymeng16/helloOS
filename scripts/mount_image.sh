IMAGE_NAME=helloOS.img

function mount_as_loop() {
  # check if the disk image is mounted as loop
  LOOP_DEVICE_NAME=$(losetup -a | grep $IMAGE_NAME | sed 's/|/ /' | awk '{print $1}' | cut -d':' -f 1)
  if [ "$LOOP_DEVICE_NAME" ]; then
    echo "$IMAGE_NAME is mounted to $LOOP_DEVICE_NAME, unmount now..."
    sudo kpartx -d $IMAGE_NAME
  fi

  sudo kpartx -av $IMAGE_NAME
  LOOP_DEVICE_NAME=$(losetup -a | grep $IMAGE_NAME | sed 's/|/ /' | awk '{print $1}' | cut -d':' -f 1)
}


if [ -f "$IMAGE_NAME" ]; then
  echo "$IMAGE_NAME exists, image creation skipped..."
  mount_as_loop

else
  echo "$IMAGE_NAME does not exist, create the image (default size: 512M)."
  dd if=/dev/zero of=$IMAGE_NAME bs=1024 count=524288

  printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk "$dev"
fi



