_init_prepare_work_dir() {
  local _init_work_dir=/tmp/init

  rm -rf $_init_work_dir $_INIT_OUTPUT_FILE && mkdir -p $_init_work_dir
  cd $_init_work_dir

  mkdir -p {dev,etc,mnt/root,proc,root,sys,run,usr/bin,usr/lib,usr/lib64,usr/sbin}
  cp -a /dev/{null,console,tty} dev/

  ln -s usr/bin bin
  ln -s usr/sbin sbin
  ln -s usr/lib lib
  ln -s usr/lib64 lib64
}

_init_busybox() {
  _package_install_new_only sys-apps/busybox

  for cmd in $_BUSYBOX_CMDS; do
    ln -s busybox bin/$cmd
  done
}

_init_dependencies() {
  log_info "copying dependencies"
  tar cph -C / $(lddtree -l $_INIT_CMDS | tr '\n' ' ') 2>/dev/null | tar xp -C $_init_work_dir
}

_init_initscript() {
  log_info "copying init"
  cp $APP_LIBRARY_PATH/init/walterjwhite.sh init
  chmod +x init
}

_init_kernel_modules() {
  _gentoo_latest_kernel_version

  log_info "copying _KERNEL modules"

  _init_kernel_modulesvalidation_required
  _INIT_KERNEL_MODULES_${_MODULES_IMPLEMENTATION}

  _init_kernel_modules_metadata
}

_init_kernel_modulesvalidation_required() {
  local module_name module_file
  for module_name in $_INIT_REQUIRED_MODULES; do
    module_name=$(printf '%s\n' $module_name | sed -e 's/_/*/g')
    module_file=$(find /lib/modules/$_os_installer_latest_kernel_version -type f -name "$module_name.ko")
    [ -z "$module_file" ] && {
      log_warn "no module file found for $module_name"
      continue
    }

    tar cp -C / $module_file 2>/dev/null | tar xp -C $_init_work_dir
  done
}

_init_kernel_modules_udev() {
  local path
  for path in $_INIT_MODULE_PATHS; do
    [ ! -e /lib/modules/$_os_installer_latest_kernel_version/kernel/$path ] && {
      log_warn "module not found: /lib/modules/$_os_installer_latest_kernel_version/kernel/$path"
      continue
    }

    tar cp -C / /lib/modules/$_os_installer_latest_kernel_version/kernel/$path 2>/dev/null | tar xp -C $_init_work_dir
  done
}

_init_kernel_modules_host() {
  local module_name module_file kernel_modules
  kernel_modules=$(lsmod | sed 1d | awk {'print$1'} | sort -u | tr '\n' ' ')
  for module_name in $kernel_modules; do
    module_find_pattern=$(printf '%s\n' "$module_name" | sed -e 's/_/*/g')
    module_file=$(find /lib/modules/$_os_installer_latest_kernel_version -type f -name "$module_find_pattern.ko")
    [ -z "$module_file" ] && {
      log_warn "no module file found for $module_name"
      continue
    }

    tar cp -C / $module_file 2>/dev/null | tar xp -C $_init_work_dir
    local _kernel_host_modules="$_kernel_host_modules $module_name"
  done

  _init_host_firmware
}

_init_host_firmware() {
  local module_pattern
  for module_pattern in $(lsmod | sed 1d | awk {'print$1'} | sort -u | sed -e 's/_/*/g' -e 's/^/*/' -e 's/$/*/'); do
    find /lib/firmware -type f -path "$module_pattern" -exec tar cp -C / {} + | tar xp -C $_init_work_dir 2>/dev/null
  done
}

_init_kernel_modules_metadata() {
  tar cp -C / /lib/modules/$_os_installer_latest_kernel_version/modules.* 2>/dev/null | tar xp -C $_init_work_dir
}

_init_conf() {
  [ "$_MODULES_IMPLEMENTATION" = "host" ] && {
    $GNU_SED -i "s/KERNEL_HOST_MODULES/$_kernel_host_modules $_INIT_REQUIRED_MODULES/" init
  }
}

_init_build() {
  find . -print0 | cpio --null --create --verbose --format=newc | $_INIT_COMPRESSION_CMD >$_INIT_OUTPUT_FILE
}
