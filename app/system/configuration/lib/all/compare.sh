configuration_compare() {
  _provider_load $1
  exec_call _configuration_${1}_compare || exit_with_error "unable to compare: _configuration_${1}_compare"
}
