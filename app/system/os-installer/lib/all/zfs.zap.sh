
_zfs_zap() {
  local zap_patch_path=patches/zfs-zap.patch/zap.post-run
  mkdir -p $(dirname $zap_patch_path)

  if [ -n "$_ZFS_ZAP_SNAP" ]; then
    log_warn "detected ZFS ZAP, setting up zap"

    printf 'zfs allow -u zap bookmark,diff,hold,send,snapshot %s\n' $_zfs_volume >>$zap_patch_path

    zfs set zap:snap=on $_zfs_volume
  fi

  [ -n "$_ZFS_ZAP_TTL" ] && zfs set zap:ttl=$_ZFS_ZAP_TTL $_zfs_volume
  [ -n "$_ZFS_ZAP_BACKUP" ] && zfs set zap:backup=$_ZFS_ZAP_BACKUP $_zfs_volume

  unset _ZFS_ZAP_TTL _ZFS_ZAP_BACKUP _ZFS_ZAP_SNAP
}
