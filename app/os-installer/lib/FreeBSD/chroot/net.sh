_is_port_in_use() {
	sockstat -4 | awk {'print$6'} | grep -cqm1 :$1
}

_IPS() {
	ifconfig | grep broadcast | awk {'print$2'} | tr '\n' ' '
}
