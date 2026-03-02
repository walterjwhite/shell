_bhyve_create() {
  local _options=""

  [ -n "$_VM_SIZE" ] && _options="$_options -s $_VM_SIZE"
  [ -n "$_VM_MEMORY" ] && _options="$_options -m $_VM_MEMORY"

  [ -n "$_VM_CPUS" ] && _options="$_options -c $_VM_CPUS"
  [ -n "$_VM_TEMPLATE" ] && _options="$_options -t $_VM_TEMPLATE"

  vm create $_vm_name $_options
}

_bhyve_copy_conf() {
  cp -R $bhyve_vm_templates/$_vm_name/* /$bhyve_vm_dir/$_vm_name/

  mv /$bhyve_vm_dir/$_vm_name/vm-bhyve.conf /$bhyve_vm_dir/$_vm_name/$_vm_name.conf
}

_bhyve_image() {
  if [ -n "$_VM_ISO_FILENAME" ]; then
    [ ! -e "/$bhyve_vm_dir/.iso/$_VM_ISO_FILENAME" ] && vm iso $_VM_ISO_URL

    return
  fi

  _bhyve_cloud_image
}

_bhyve_cloud_image() {
  pkg install -y qemu-tools cdrkit-genisoimage
}

_bhyve_install() {
  export _vm_name _VM_ISO_FILENAME _VM_VERSION _VM_HOSTNAME _VM_IP_ADDRESS
  _original_wd=$PWD

  cd /$bhyve_vm_dir/$_vm_name

  log_info "installing VM: $_vm_name"

  timeout -k $_bhyve_kill_bhyve_timeout $_bhyve_timeout ./install

  cd $_original_wd

  zap snap 30d $bhyve_vm_dir/$_vm_name

  unset _VM_ISO_FILENAME _VM_ISO_URL
}

_bhyve_provision() {
  for _VM in $(find $bhyve_vm_templates -maxdepth 1 -type d ! -name 'bhyve'); do
    _vm_name=$(basename $_VM)

    log_info "preparing VM: $_vm_name"

    if [ $(vm list | sed 1d | awk {'print$1'} | grep -c $_vm_name) -gt 0 ]; then
      log_warn "vm $_vm_name is already installed, aborting"
      continue
    fi

    log_info "reading conf for VM: $_vm_name"
    . $bhyve_vm_templates/$_vm_name/configuration

    _bhyve_create
    _bhyve_copy_conf

    _bhyve_image

    _bhyve_install
  done
}

_bhyve_init() {
  [ -n "$_bhyve_init" ] && return 0

  bhyve_vm_templates=/usr/local/etc/walterjwhite/bhyve

  if [ ! -e $bhyve_vm_templates ]; then
    log_warn "path does not exist: $bhyve_vm_templates"
    return 1
  fi

  if [ ! -e ~/.ssh/authorized_keys ]; then
    log_warn "authorized_keys file does *NOT* exist at ~/.ssh/authorized_keys, it is required to SSH into guests"
    return 1
  fi

  _package_install_new_only $conf_system_configuration_bhyve_required_packages

  sysrc vm_enable=YES

  sysrc cloned_interfaces="bridge0 tap0"
  sysrc ifconfig_bridge0_name="${_BHYVE_INTERFACE}bridge"
  sysrc ifconfig_${_BHYVE_INTERFACE}bridge="addm ${_BHYVE_INTERFACE} addm tap0 up"

  sysrc -f /boot/loader.conf vmm_load=YES



  dev_name=$(zfs list | grep ROOT | awk {'print$1'} | grep ROOT$ |
    sed -e "s/\/ROOT//" |
    head -1)

  bhyve_vm_dir=$dev_name/bhyve

  sysrc vm_dir="zfs:$bhyve_vm_dir"

  zfs create $bhyve_vm_dir

  _bhyve_kill_bhyve_timeout=1m
  _bhyve_timeout=5m

  _bhyve_virtio_version=0.1.266-1
  _bhyve_virtio_file_version=0.1.266
  _bhyve_virtio_filename=virtio-win-$_bhyve_virtio_file_version.iso
  curl -o /$bhyve_vm_dir/$_bhyve_virtio_filename https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-$_bhyve_virtio_version/$_bhyve_virtio_filename

  vm init

  vm switch create public 2>/dev/null
  vm switch add public $_BHYVE_INTERFACE 2>/dev/null

  _ssh_public_key=$(cat ~/.ssh/authorized_keys)

  _bhyve_init=1
}

system_configuration_bhyve() {
  _bhyve_init && _bhyve_provision
}
