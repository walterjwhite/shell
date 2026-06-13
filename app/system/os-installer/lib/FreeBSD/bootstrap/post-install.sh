_post_install() {
  umask 077
  for i in /entropy /boot/entropy; do
    i="$conf_os_installer_mountpoint/$i"
    dd if=/dev/random of="$i" bs=4096 count=1
    chown 0:0 "$i"
  done
}
