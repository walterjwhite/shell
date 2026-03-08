
_trivy_scan() {
  local scan_type="$1"
  shift

  local reference_file=$APP_DATA_PATH/trivy/$git_project_relative_path/$(gcb)/$scan_type

  mkdir -p "$(dirname "$reference_file")"

  _trivy_output_file="$(_mktemp_mktemp)"
  exit_defer _trivy_cleanup

  trivy -q "$@" >"$_trivy_output_file"


  if [ -e "$reference_file" ]; then
    log_warn "trivy - $scan_type - comparing with existing scan"

    diff "$_trivy_output_file" "$reference_file" >/dev/null && {
      log_info "trivy - $scan_type - no changes detected"
      rm -f "$_trivy_output_file"
      return
    }
  else
    log_warn "trivy - $scan_type - no existing scan found"

    [ $(wc -l <"$_trivy_output_file") -eq 0 ] && {
      log_info "trivy - $scan_type - no findings found"
      rm -f "$_trivy_output_file"
      return
    }

    cat "$_trivy_output_file"
  fi

  _stdin_continue_if "trivy - $scan_type - do you accept the findings above?" "Y/n" || exit_with_error "user aborted"

  log_info "trivy - $scan_type - user accepted scan findings - saving scan to $reference_file"
  mv "$_trivy_output_file" "$reference_file"
}

_trivy_cleanup() {
  rm -rf "$_trivy_output_file"
  find /tmp -name 'analyzer-fs-' -exec rm -rf {} +
}
