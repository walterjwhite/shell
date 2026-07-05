_net_is_port_in_use() {
  ss -tuln | grep -Pcqm1 ':$1[\s]'
}

_net_ips() {
  ip -o -f inet addr show | awk '$3 !~ /lo/ && $4 !~ /127.0.0.1/ {print $4}' | tr '\n' ' '
}
