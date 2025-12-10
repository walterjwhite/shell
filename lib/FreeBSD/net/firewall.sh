_firewall_flush_table() {
	_require "$1" "table name is required"

	_pfctl -t $1 -T flush
}

_firewall_update_table() {
	local table_name=$1
	shift

	_require "$table_name" "table name is required"
	[ $# -eq 0 ] && _ERROR "IP address(es) to add is required"

	_pfctl -t $table_name -T add "$*"
}

_firewall_update_table_from_file() {
	_pfctl -t $TABLE_NAME -T replace -f $1
}

_firewall_check() {
	service pf check
}

_firewall_restart() {
	service pf restart
}
