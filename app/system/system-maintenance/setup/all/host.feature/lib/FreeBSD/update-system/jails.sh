lib jail.sh

_patch_jails() {
  _logging_context=jail
  log_info "inspecting"

  _on_jail=1
  for _JAIL_PATH in $(_get_jail_paths); do
    _jail_volume=$(_get_jail_volume $_JAIL_PATH)

    _jail_name=$(basename $_jail_volume)

    _logging_context=jail.$_jail_name

    _freebsd_update_options="-j $_jail_name"
    _pkg_update_options="-j $_jail_name"
    _checkrestart_options="-j $_jail_name"

    conf_system_maintenance_patch_types="FREEBSD_UPGRADE USERLAND FREEBSD"

    _patch
  done
}
