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

  log_info "starting password crack (this may take a while)..."
  john "$hash_file"

  local status=$?
  if [ $status -eq 0 ]; then
    exit_with_success "password cracked!"
    john --show "$hash_file"
  else
    log_warn "password not cracked yet or interrupted"
  fi

  log_remove_context
}

_extract_hash() {
  local hex_data=$(dscl . -read /Users/"$target_user" dsAttrTypeNative:ShadowHashData | tail -n +2 | tr -d ' \n')

  [ -z "$hex_data" ] && {
    exit_with_error "failed to read ShadowHashData for $target_user"
  }

  local json_plist=$(printf '%s' "$hex_data" | xxd -r -p | plutil -extract SALTED-SHA512-PBKDF2 xml1 -o - - | yq -M -p=xml -o=json)

  [ -z "$json_plist" ] && {
    exit_with_error "failed to extract SALTED-SHA512-PBKDF2 from plist"
  }

  local entropy_b64=$(printf '%s' "$json_plist" | jq -r '.plist.dict.data[0]')
  local salt_b64=$(printf '%s' "$json_plist" | jq -r '.plist.dict.data[1]')
  local iterations=$(printf '%s' "$json_plist" | jq -r '.plist.dict.integer')

  if [ -z "$entropy_b64" ] || [ -z "$salt_b64" ] || [ -z "$iterations" ] || [ "$entropy_b64" = "null" ]; then
    exit_with_error "failed to parse JSON plist components"
  fi

  local entropy_hex=$(printf '%s' "$entropy_b64" | base64 -D | xxd -p | tr -d '\n')
  local salt_hex=$(printf '%s' "$salt_b64" | base64 -D | xxd -p | tr -d '\n')

  printf '%s:\$pbkdf2-hmac-sha512\$%s.%s.%s\n' "$target_user" "$iterations" "$salt_hex" "$entropy_hex"
}
