lib ./git.archive.sh
lib ssh.sh

_incus_setup_profile() {
  incus profile show default >/dev/null 2>&1 || exec_wrap incus admin init --auto

  incus profile show default | grep network | grep -cqm1 incusbr0 || {
    log_info "creating default networking conf"
    incus profile device add default eth0 nic network=incusbr0 name=eth0
  }

  incus profile show default | grep -A3 root | grep -A2 -B1 'path: /' | grep -A2 -B1 'pool: default' | grep -qm1 'type: disk' || {
    log_warn "adding disk to default profile"

    local zfs_root_dev_name=$(zfs get -H name / | awk {'print$1'} | cut -f1 -d/ | head -1)
    incus storage create default zfs source=$zfs_root_dev_name/incus

    exec_wrap incus profile device add default root disk pool=default path=/

    return
  }

  log_warn "default profile already contains disk device"
}

_incus_provision_container() {

  cd /tmp

  . $_INCUS_CONFIGURATION_FILE
  _incus_configuration_file_path=$(dirname $_INCUS_CONFIGURATION_FILE)
  _container_name=$os_installer_container_branch
  _container_path=/var/lib/incus/storage-pools/default/containers/$_container_name/rootfs
  _container_type=incus

  export _container_type=$_container_type
  export _container_name=$_container_name

  log_add_context "incus-$_container_name"

  conf_os_installer_system_name=$_container_name
  incus config show $_container_name >/dev/null 2>&1
  if [ $? -gt 0 ]; then
    log_detail "creating new instance [$_container_name]"
    exec_wrap incus launch images:$os_installer_container_image $_container_name
  else
    log_warn "using existing instance [$_container_name]"

    incus info $_container_name | grep Status | cut -f2 -d: | grep -cqm1 RUNNING || {
      log_detail "starting container"
      exec_wrap incus start $_container_name
    }
  fi

  incus config set $_container_name boot.host_shutdown_timeout=30

  o_os_installer_mountpoint=$conf_os_installer_mountpoint
  conf_os_installer_mountpoint=$_container_path

  mkdir -p $_container_path/tmp
  target=$_container_path _ssh_use_host_ssh_conf


  $GNU_SED -i 's/^hosts:.*/hosts: mymachines files myhostname dns/' $_container_path/etc/nsswitch.conf

  exec_wrap _prepare_chroot
  _init_chroot_ssh
  _init_chroot_app_conf

  local o_workspace=$conf_os_installer_system_workspace
  export conf_os_installer_system_workspace=/os
  exec_wrap _setup_git
  exec_wrap _write_system

  _incus_mount_kernel_src

  incus exec $_container_name -- systemctl restart systemd-resolved

  exec_call _incus_instance_prepare

  incus exec \
    --env _in_container=1 \
    --env conf_os_installer_system_name=$_container_name \
    --env logging_context=$logging_context \
    --env container=lxc $_container_name \
    --env add_log_context=incus-$_container_name \
    --env conf_os_installer_system_workspace=/os \
    --env optn_git_mirror=$optn_git_mirror \
    $APP_PLATFORM_PATH/$APPLICATION_NAME/bin/chroot

  exec_call _incus_instance_cleanup_running


  conf_os_installer_system_workspace=$o_workspace

  _incus_post_setup

  incus stop $_container_name

  exec_call _incus_instance_cleanup_stopped

  log_detail "creating ZFS snapshot"
  zap snap $os_installer_zap_snapshot_retention_duration default/containers/$_container_name

  conf_os_installer_mountpoint=$o_os_installer_mountpoint

  log_remove_context

  unset _container_type _container_name
}

_incus_mount_kernel_src() {
  [ -e /usr/src ] && {
    mkdir -p $_container_path/usr/src
    mount --bind /usr/src $_container_path/usr/src

    exit_defer umount $_container_path/usr/src
  }
}

_incus_start() {
  systemctl enable incus && systemctl enable incus-user
  systemctl start incus && exit_defer systemctl stop incus
  systemctl start incus-user && exit_defer systemctl stop incus
}

_incus_post_setup() {
  if [ -e $_incus_configuration_file_path/post-setup ]; then
    log_info "running post-setup scripts for $_container_name"

    local post_setup_script
    for post_setup_script in $(find $_incus_configuration_file_path/post-setup -type f | sort); do
      log_info "running $post_setup_script"
      . $post_setup_script
    done
  fi
}
