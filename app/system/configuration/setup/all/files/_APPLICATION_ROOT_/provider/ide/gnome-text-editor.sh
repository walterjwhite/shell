lib gsettings.sh

which gedit >/dev/null 2>&1 || {
  return
}

provider_path=~/.config
provider_path_is_dir=1
provider_path_is_skip_prepare=1
provider_no_root_user=1

_configuration_gnome_text_editor_backup() {
  _gsettings_dump org.gnome.TextEditor
}

_configuration_gnome_text_editor_restore() {
  _gsettings_restore org.gnome.TextEditor 2>/dev/null
}

_configuration_gnome_text_editor_clear() {
  :
}
