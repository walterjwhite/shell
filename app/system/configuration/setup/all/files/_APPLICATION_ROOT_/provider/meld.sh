lib gsettings.sh

which meld >/dev/null 2>&1 || {
  return
}

provider_path=~/.config
provider_path_is_dir=1
provider_path_is_skip_prepare=1
provider_no_root_user=1

_configuration_meld_backup() {
  _gsettings_dump org.gnome.meld
}

_configuration_meld_restore() {
  _gsettings_restore org.gnome.meld 2>/dev/null
}

_configuration_meld_clear() {
  :
}
