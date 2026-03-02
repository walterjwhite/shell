secrets_put() {
  [ -n "$from_file" ] && {
    case "${from_file}" in
    ~*)
      local from_file="${HOME}$(printf '%s' "${from_file}" | sed 's/^~//')"
      ;;
    *)
      :
      ;;
    esac

    log_warn "reading secret from file: $from_file"
    secret_value=$(cat $from_file)
    return
  }

  _stdin_read_ifs "Enter secret value" secret_value && _stdin_read_ifs "Enter secret value AGAIN" secret_value2

  [ "$secret_value" == "$secret_value2" ] && return

  exit_with_error "passwords do not match"
}
