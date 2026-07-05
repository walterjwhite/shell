_link_create() {
  local _target=$1
  local _link_path=$2
  ln -s "$_target" "$_link_path"
}

_link_install_link() {
  local _target=$1
  local _link_path=$2
  _link_create "$_target" "$_link_path" &&
    printf '%s\n' "$_link_path" >>"$install_library_path/$target_application_name/.files"
}
