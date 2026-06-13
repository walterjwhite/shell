lib io/file.sh

feature_install() {
  feature=$1

  feature_key=$(printf '%s' $feature | sed -e 's/\.feature/\.feature\n/g' | $GNU_GREP -Po '/[a-zA-Z0-9-_]*.feature$' | sed -e 's/^\///' -e 's/\.feature$//' | tr '\n' '_' | sed -e 's/_$//')
  feature_name=$(printf '%s' $feature_key | sed -e 's/^.*.feature//')

  _settings_application_defaults $feature
  _is_feature_enabled $feature_key && _feature_apply

  unset _feature
  return 0
}

_feature_apply() {
  _setup_main $feature/setup
  _setup_main $feature/post-setup
}

feature_is_installed() {
  :
}

feature_is_latest() {
  :
}
