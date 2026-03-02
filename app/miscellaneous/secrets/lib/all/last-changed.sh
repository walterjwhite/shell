secrets_last_changed() {
  local directory=$1
  shift

  local extension=$1
  shift

  cd $directory
  for secret_key in $(secrets find "$@"); do
    secrets_last_changed $secret_key
  done | sort -k2
}

_secrets_last_changed() {
  printf '%75s %s\n' "$1" $(git log --format=%as --max-count=1 $pass_options $1.$extension)
}
