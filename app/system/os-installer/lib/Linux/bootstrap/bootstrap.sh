_get_underlying_device() {
  lsblk -o NAME,TYPE | grep -B1 "luks-" | awk 'NR==1{print $1}' | grep -Po '[a-zA-Z0-9]+' | sed -e 's/[[:digit:]]$//'
}
