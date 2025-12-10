_is_port_in_use() {
	netstat -tuln | awk {'print$4'} | grep -cqm1 :$1
}

_IPS() {
	ip -o -f inet addr show | awk '$3 !~ /lo/ && $4 !~ /127.0.0.1/ {print $4}' | tr '\n' ' '
}
