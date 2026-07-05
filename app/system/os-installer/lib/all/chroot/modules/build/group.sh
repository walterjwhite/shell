patch_group() {
  _module_find_callback _group_add
}

_group_add() {
  . $1

  log_detail "add group: $1 $groupName $gid"
  pw groupadd -n $groupName -g $gid

  unset groupName gid
}
