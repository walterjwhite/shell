kernel_type=d
kernel_path=kernel

patch_kernel() {
  [ -n "$_in_container" ] && return

  _kernel_patch_path=$conf_os_installer_system_workspace/patches/physical/kernel-auto-generated.patch/_kernel
  mkdir -p $_kernel_patch_path

  _kernel_handle_containers
  _kernel_append $(_module_find)

  __kernel_source

  printf '# build a kernel targetted for this hardware only\nCPUTYPE?=native\n\n' >>/etc/make.conf

  __kernel_modules_conf
  __kernel_kernel_conf

  __kernel_build

  $GNU_SED -i "s/Components src world kernel/Components src world/" /etc/freebsd-update.conf

  log_info "kernel build complete"
}

_kernel_handle_containers() {
  log_detail "processing container kernel configurations"

  local container_mountpoint
  for container_mountpoint in $(_container_mount_points); do
    _kernel_append $(find $container_mountpoint/tmp/os -type d -name "kernel")
  done
}

_kernel_append() {
  [ $# -eq 0 ] && return

  log_detail "appending kernel conf - $*"

  find "$@" -type f -path '*/kernel/kernel' -exec $GNU_GREP -Pvh '(^#|^$)' {} + >>$_kernel_patch_path/kernel 2>/dev/null
  find "$@" -type f -path '*/kernel/modules' -exec $GNU_GREP -Pvh '(^#|^$)' {} + >>$_kernel_patch_path/modules 2>/dev/null
}

__kernel_source() {
  local _system_version=$(printf '%s' $os_installer_version | sed -e "s/\-.*//")
  local _system_architecture=$(uname -m)

  local _system_configuration=/usr/src/sys/$_system_architecture/conf
  if [ ! -e $_system_configuration ]; then
    git clone -b releng/$_system_version --depth 1 https://git.freebsd.org/src.git /usr/src
  fi
}

__kernel_modules_conf() {
  if [ -e $_kernel_patch_path/modules ]; then
    grep -cqm1 cpuctl $_kernel_patch_path/modules || {
      log_warn "enabling CPU microcode update support by including cpuctl as a kernel module"
      printf 'cpuctl\n' >>$_kernel_patch_path/modules
    }

    printf 'MODULES_OVERRIDE=%s\n\n' "$($GNU_GREP -Pvh '(^$|^#)' $_kernel_patch_path/modules | sort -u | tr '\n' ' ')" >>/etc/make.conf
  fi
}

__kernel_kernel_conf() {
  grep -v 'ident ' $_kernel_patch_path/kernel >$_system_configuration/custom
}

__kernel_build() {
  mkdir -p /tmp/kernel-build

  log_info "building $_system_architecture kernel"

  cd /usr/src

  __kernel_build_do build
  __kernel_build_do install

  _kernel_output
}

__kernel_build_do() {
  make ${1}kernel KERNCONF=custom >/tmp/kernel-build/$1.out 2>/tmp/kernel-build/$1.err || {
    _kernel_output $1
    return 2
  }
}

_kernel_output() {
  if [ $# -gt 0 ]; then
    log_warn "$1 kernel failed"
    cat /tmp/kernel-build/$1.out /tmp/kernel-build/$1.err
  fi
}
