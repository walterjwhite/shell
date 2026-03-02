_is_feature_enabled() {
  local feature_key=$(_feature_key $1)
  set | grep -cqm1 "^${feature_key}_disabled=1$" && {
    log_warn "$1 is disabled"
    return 1
  }

  return 0
}

_feature_key() {
  printf '%s\n' "feature_${1}" | tr '-' '_'
}
