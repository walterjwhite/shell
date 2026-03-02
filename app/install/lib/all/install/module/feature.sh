lib io/file.sh

feature_install() {
  local _feature=$1

  feature_key=$(printf '%s' $_feature | sed -e 's/\.feature/\.feature\n/g' | $GNU_GREP -Po '/[a-zA-Z0-9-_]*.feature$' | sed -e 's/^\///' -e 's/\.feature$//' | tr '\n' '_' | sed -e 's/_$//')
  feature_name=$(printf '%s' $feature_key | sed -e 's/^.*.feature//')

  _settings_application_defaults $_feature
  _is_feature_enabled $feature_key && _feature_apply

  unset _feature
  return 0
}

_feature_apply() {
  _setup_main $_feature/setup
  _setup_main $_feature/post-setup
}
