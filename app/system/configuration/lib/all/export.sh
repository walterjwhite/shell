lib io/file.sh

_configuration_export() {
  file_require ~/.config/walterjwhite/shell/.configuration-public

  [ ! -e ~/.data/configuration ] && exit_with_error "no configuration found at ~/.data/configuration"

  configuration_tmpdir=$(_mktemp_options=d _mktemp_mktemp)
  log_info "exporting configuration to: $configuration_tmpdir"

  for provider_name in $($GNU_GREP -Pvh '^(#|$)' ~/.config/walterjwhite/shell/.configuration-public); do
    provider_function_name=$(printf '%s' $provider_name | tr '-' '_')
    log_add_context "$provider_name"
    log_detail exporting

    _provider_load $provider_name

    exec_call _configuration_${provider_function_name}_export || _configuration_export_default || {
      log_warn "error while exporting, $?"
      continue
    }

    exec_call _configuration_${provider_function_name}_export_post

    log_detail exported

    log_remove_context
  done
}

_configuration_export_default() {
  mkdir -p $configuration_tmpdir/$provider_name

  tar -cp -C ~/.data/configuration/$provider_name . 2>/dev/null | tar -xp -C $configuration_tmpdir/$provider_name
}

configuration_export_remove_home_refs() {
  log_detail "removing home refs"
  find $configuration_tmpdir/$provider_name -type f -exec $GNU_SED -i "s|$HOME|\$HOME|g" {} +
}
