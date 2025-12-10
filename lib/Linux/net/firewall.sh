lib io/file.sh

_firewall_flush_table() {
	_require "$1" "_firewall_flush_table:table name[1]"

	nft flush set ip global $1
}

_firewall_update_table() {
	_require "$1" "_firewall_update_table:table name[1]"
	_require "$2" "_firewall_update_table:IP address[2]"

	nft add element ip global $1 { $2 }
}

_firewall_update_table_from_file() {
	_has_contents $1 || {
		_WARN "table is empty: $1"
		return
	}

	local table_name=$2
	[ -z "$table_name" ] && table_name=$(basename $(dirname $1))_$(basename $1)

	table_name=$(printf '%s' $table_name | tr '/' '_' | tr '-' '_' | sed -e 's/\.[[:alnum:]]*$//')

	nft flush set ip global $table_name

	xargs -a $1 -d '\n' -n 5000 |
		sed -e 's/ /, /g' |
		xargs -I {} nft add element ip global $table_name { {} }
}

_firewall_check() {
	nft -cf /usr/local/etc/walterjwhite/firewall/main.nft
}

_firewall_restart() {
	nft -f /usr/local/etc/walterjwhite/firewall/main.nft
}
