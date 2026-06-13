_ip_ip() {
  ifconfig -a | grep inet | awk -F ' ' '{print $2 }' |
    "$GNU_GREP" -Po '[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}' |
    grep -v 127.0.0.1 | sort -u | head -1
}
