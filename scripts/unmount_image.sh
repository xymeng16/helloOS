IMAGE_NAME=helloOS.img
MOUNT_POINT="image"

function unmount_all() {
  if [[ "$(grep 'helloOS' /proc/mounts)" ]]; then
  echo "$IMAGE_NAME have already been mounted to $(pwd)/$MOUNT_POINT..."
    sudo umount $MOUNT_POINT
  fi

  LOOP_DEVICE_NAME=$(losetup -a | grep $IMAGE_NAME | sed 's/|/ /' | awk '{print $1}' | cut -d':' -f 1)
  if [ "$LOOP_DEVICE_NAME" ]; then
    echo "$IMAGE_NAME is mounted to $LOOP_DEVICE_NAME, unmount it now..."
    sudo losetup -d $LOOP_DEVICE_NAME
  fi
}

unmount_all