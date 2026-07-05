lib io/file.sh

_audit_password() {
  log_add_context "$target_user"

  log_info "auditing password"

  local hash_file="$(_mktemp_mktemp)"
  exit_defer rm -f "$hash_file"

  _extract_hash >"$hash_file" || {
    exit_with_error "failed to extract hash"
  }

  if [ ! -s "$hash_file" ]; then
    exit_with_error "empty hash extracted"
  fi

  log_info "hash extracted to $hash_file"
  log_debug "$(cat $hash_file)"

  local unshadow_file="$(_mktemp_mktemp)"
  exit_defer rm -f "$unshadow_file"
  unshadow /etc/passwd "$hash_file" >"$unshadow_file" || exit_with_error "failed to unshadow"

  log_info "starting password crack (this may take a while)..."
  john "$unshadow_file"

  exit_with_success "password cracked!"
  john --show "$unshadow_file"

  log_remove_context
}

_extract_hash() {
  grep "^$target_user:" /etc/shadow
}
