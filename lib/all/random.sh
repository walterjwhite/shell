_random_random() {
  local length=$conf_install_random_default_length
  [ -n "$1" ] && {
    length=$1
    shift
  }

  openssl rand -base64 $length

}
