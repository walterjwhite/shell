_runtime_exec() {
  log_detail "$*"
  "$@" || {
    log_warn "init error: $?"

    [ -n "$warn_on_error" ] && return

    _on_exit
  }

  log_info "completed: $*"
}

_on_exit() {
  exec /bin/sh

  return 1
}

_mount_filesystems() {
  mount -t proc proc /proc
  mount -t sysfs sysfs /sys
  mount -t devtmpfs devtmpfs /dev
  mount -t tmpfs -o rw,nosuid,nodev,relatime,mode=755 none /run
}

_modules_udev() {
  /usr/lib/systemd/systemd-udevd --daemon --resolve-names=never
  udevadm trigger
  udevadm settle
}

_modules_host() {
  modprobe -a KERNEL_HOST_MODULES
  return 0
}

_process_cmdline() {
  overlayfs_size=$(cat /proc/cmdline | tr ' ' '\n' | grep overlayfs.size | cut -f2 -d=)
  [ -n "$overlayfs_size" ] && {
    _overlayfs_size=$overlayfs_size
    log_detail "overlayfs size: $_overlayfs_size"
  }

  _luks_device_uuid=$(cat /proc/cmdline | tr ' ' '\n' | grep luks.uuid | cut -f2 -d=)
  log_detail "luks uuid: $_luks_device_uuid"

  _ram_disabled=$(cat /proc/cmdline | tr ' ' '\n' | grep ram.disabled | cut -f2 -d=)
  log_detail "ram disabled: $_ram_disabled"

  cat /proc/cmdline | grep -qm1 'init.debug' >/dev/null 2>&1 && {
    log_detail "enabling init debug"
    set -x
  }
}

_wait_for_device() {
  local tries=3

  while [ $tries -gt 0 ]; do
    _luks_device_path=$(findfs UUID=$_luks_device_uuid)
    [ -n "$_luks_device_path" ] && return

    sleep 3
    tries=$(($tries - 1))
  done

  return 1
}

_cryptsetup_open() {
  _stdin_read_ifs "Enter passphrase for $_luks_device_path" _LUKS_KEY
  printf '%s' "$_LUKS_KEY" | cryptsetup luksOpen $_luks_device_path luks-$_luks_device_uuid
}

_mount_root_volume() {
  exec_wrap mkdir -p /run/root-volume
  exec_wrap mount -o ro /dev/mapper/luks-$_luks_device_uuid /run/root-volume
}

_runtime_ram() {
  [ -n "$_ram_disabled" ] && return 1

  system_memory=$(cat /proc/meminfo | grep MemTotal | awk {'print$2'})
  system_memory=$(($system_memory * 1024))

  root_imgsize=$(stat -c %s /run/root-volume/root-squashfs.img)
  memory_required=$(($root_imgsize + $_overlayfs_size))
  [ $memory_required -ge $system_memory ] && {
    log_detail "system has insufficent memory to run in memory"
    _volume_path=root-volume
    return
  }

  log_detail "resizing /run volume to match size of images: [$root_imgsize] [$system_memory]"
  mount -o remount,size=$root_imgsize /run

  mkdir -p /run/root-image

  log_detail 'copying image into memory'
  rsync -h --info=progress /run/root-volume/root-squashfs.img /run/root-image/root-squashfs.img
  log_detail 'copied image into memory'

  _volume_path=root-image
}

_runtime_overlay() {
  [ ! -e /run/$_volume_path/$1-squashfs.img ] && return

  local _target_mount=$2
  [ -z "$_target_mount" ] && _target_mount=/mnt/$1-rw

  mkdir -p /mnt/$1-overlay /mnt/$1-ro $_target_mount

  mount /run/$_volume_path/$1-squashfs.img /mnt/$1-ro

  mount -t tmpfs -o size=$_overlayfs_size tmpfs /mnt/$1-overlay

  mkdir -p /mnt/$1-overlay/rw /mnt/$1-overlay/work
  mount -t overlay overlay -o lowerdir=/mnt/$1-ro,upperdir=/mnt/$1-overlay/rw,workdir=/mnt/$1-overlay/work $_target_mount
  unset _target_mount
}

_read_rw() {
  /mnt/root-rw/usr/local/bin/read-rw mnt/root-rw
}

_runtime_cleanup() {
  [ "$_volume_path" != "root-volume" ] && {
    umount /run/root-volume
    cryptsetup luksClose luks-$_luks_device_uuid
  }

  mkdir -p /mnt/live

  mount -o remount,rw /run/root-volume
  mount --bind /run/root-volume /mnt/live

  unset OVERLAYFS_SIZE VOLUME_PATH LUKS_DEVICE_UUID
}

_switch_root() {
  mount --move /proc /mnt/root-rw/proc
  mount --move /sys /mnt/root-rw/sys
  mount --move /dev /mnt/root-rw/dev

  mkdir -p /mnt/root-rw/mnt/overlay/root
  mount --bind /mnt/root-overlay/rw /mnt/root-rw/mnt/overlay/root
  log_detail "changes are visible @ /mnt/overlay"

  exec switch_root /mnt/root-rw /sbin/init
}
