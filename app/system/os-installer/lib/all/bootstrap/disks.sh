_select_disk() {
  local device_serial_number=$(_disk_serial $conf_os_installer_disk_dev)

  required_message="device serial number not found for: $conf_os_installer_disk_dev" validation_require "$device_serial_number" "device_serial_number"

  local device_serial_number_entry
  local device_serial_number_entry_key
  local device_serial_number_entry_value
  for device_serial_number_entry in $(printf '%s\n' $conf_os_installer_dev_name_map); do
    device_serial_number_entry_key=${device_serial_number_entry%%:*}
    device_serial_number_entry_value=${device_serial_number_entry#*:}

    if [ "$device_serial_number_entry_key" = "$device_serial_number" ]; then
      _os_installer_zfs_pool_name=z_${device_serial_number_entry_value}
      conf_os_installer_disk_dev_id=$device_serial_number_entry_key
      conf_os_installer_disk_dev_name=$device_serial_number_entry_value

      log_info "using $conf_os_installer_disk_dev [$_os_installer_zfs_pool_name|$conf_os_installer_disk_dev_name]"

      _warn_if_using_failing_disk $device_serial_number_entry_value

      conf_os_installer_mountpoint=$conf_os_installer_mountpoint/$_os_installer_zfs_pool_name
      return
    fi
  done
}

_warn_if_using_failing_disk() {
  [ -z "$conf_os_installer_failing_devs" ] && return

  local failing_dev
  local failing_dev_id
  for failing_dev in $(printf '%s\n' $conf_os_installer_failing_devs); do
    failing_dev_id=$(printf '%s' $failing_dev | sed -e 's/:.*$//')
    if [ "$conf_os_installer_disk_dev_name" = "$failing_dev_id" ]; then
      log_warn "using a failing device: $failing_dev"
      return 1
    fi
  done
}

_init_disk_backup() {
  git clone --depth 1 $conf_os_installer_disk_git_url $conf_os_installer_mountpoint/tmp/disk || exit_with_error "unable to clone $conf_os_installer_disk_git_url"

  local opwd=$PWD
  cd $conf_os_installer_mountpoint/tmp/disk

  mkdir -p $conf_os_installer_disk_dev_name/activity

  _backup_disk_encryption_headers
  _backup_disk_smartctl_stats
  _backup_disk_layout

  _init_git_config

  git add $conf_os_installer_disk_dev_name
  git commit $conf_os_installer_disk_dev_name -m "Backup $conf_os_installer_disk_dev_name"
  git push

  cd $opwd

  rm -rf /tmp/disk
}

_init_git_config() {
  [ -e ~/.gitconfig ] && return 0

  git config --global user.email "$(whoami)@$(hostname)"
  git config --global user.name "$(whoami)@$(hostname)"
}

_backup_disk_smartctl_stats() {
  local drive_smart_activity_file=$conf_os_installer_disk_dev_name/activity/$(date +%Y/%m/%d-%H.%M.%S)
  mkdir -p $(dirname $drive_smart_activity_file)

  smartctl -a ${conf_os_installer_disk_dev} |
    $GNU_GREP -P '^[\s]*[\d]+ [\w-]{3,}' \
      >$drive_smart_activity_file
}

_zpool_import() {
  zpool import -NR $conf_os_installer_mountpoint $_os_installer_zfs_pool_name
}
