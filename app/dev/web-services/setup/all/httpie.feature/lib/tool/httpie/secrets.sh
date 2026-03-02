_secrets_init() {
  for _SECRET in $(find $_REQUEST_KEY/secrets -type f 2>/dev/null); do
    local _SECRET_KEY=$(basename $_SECRET)
    if [ $(wc -l <$_SECRET) -eq 1 ]; then
      export $_SECRET_KEY=$(secrets -out=stdout get $(cat $_SECRET))
    else
      local _UNINITIALIZED_SECRETS="$_UNINITIALIZED_SECRETS $_SECRET_KEY"
    fi

    unset _SECRET_KEY
  done
}

_secrets_init_uninitialized() {
  if [ -n "$_UNINITIALIZED_SECRETS" ]; then
    for _UNINITIALIZED_SECRET in $_UNINITIALIZED_SECRETS; do
      local _VALUE=$(env | grep "^${_UNINITIALIZED_SECRET}=.*$")
      validation_require "$_VALUE" $_UNINITIALIZED_SECRET 1

      unset _VALUE
    done
  fi
}
