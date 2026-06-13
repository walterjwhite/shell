_amazon_href() {
  [ -z "$1" ] && return 1

  printf '%s' "$1" | sed -e "s/\/ref=.*$//"
}
