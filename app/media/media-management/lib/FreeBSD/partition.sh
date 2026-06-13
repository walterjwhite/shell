_media_partition_drive() {
  sgdisk -Z $_MEDIA_DRIVE

  sgdisk -g $_MEDIA_DRIVE

  sgdisk -n 1:0:0 -t 1:8300 $_MEDIA_DRIVE

  sgdisk -b /tmp/disk.sgdisk $_MEDIA_DRIVE
}
