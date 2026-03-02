lib gsettings.sh

which gsettings >/dev/null 2>&1 || {
  return
}

provider_path=~/.config
provider_path_is_dir=1
provider_path_is_skip_prepare=1
provider_no_root_user=1

_configuration_gnome_desktop_interface_backup() {
  _gsettings_dump org.gnome.desktop.interface
}

_configuration_gnome_desktop_interface_restore() {
  _gsettings_restore org.gnome.desktop.interface 2>/dev/null
}

_configuration_gnome_desktop_interface_clear() {
  :
}
