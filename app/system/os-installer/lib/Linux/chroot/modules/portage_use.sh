use_path=use
patch_use() {
  local use=$(_module_find_filtered | sort -u | tr '\n' ' ')

  [ -z "$use" ] && return

  printf '# portage use - patches\nUSE="$USE %s"\n' "$use" >>/etc/portage/make.conf
}
