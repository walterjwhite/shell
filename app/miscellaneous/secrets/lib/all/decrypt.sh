_secrets_decrypt() {
  local encryption_output_file=$(printf '%s' "$_ENCRYPTION_SOURCE_FILE" | sed -e 's/\.asc$//' -e 's/\.gpg$//')
  [ -e "$encryption_output_file" ] && exit_with_error "output file already exists: $encryption_output_file"

  log_info "writing decrypted file to: $encryption_output_file"
  gpg --decrypt $_ENCRYPTION_SOURCE_FILE >$encryption_output_file
}
