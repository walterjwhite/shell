patch_fstab() {
  _module_find_callback _fstab_add
}

_fstab_add() {
  local _fstab=$1
  local patch_name=$(_module_get_patch_name $_fstab)

  printf '# %s\n' "$patch_name" >>/etc/fstab
  cat $_fstab >>/etc/fstab
  printf '\n' >>/etc/fstab
  unset _fstab patch_name
}
