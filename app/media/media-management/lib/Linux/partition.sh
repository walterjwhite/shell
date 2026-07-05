_media_partition_drive() {
  sudo_run sgdisk -Z $media_drive

  sudo_run sgdisk -g $media_drive

  sudo_run sgdisk -n 1:0:0 -t 1:8300 $media_drive

  mkdir -p $media_volume_name
  sudo_run sgdisk -b $media_volume_name/sgdisk $media_drive
  sudo_run chown $sudo_user:$sudo_user $media_volume_name/sgdisk

  git add $media_volume_name/sgdisk
}
