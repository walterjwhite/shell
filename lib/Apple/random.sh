_random_random() {
  local _random_length=$1

  openssl rand -base64 $_random_length
}
