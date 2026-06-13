lib io/file.sh

_firewall_flush_table() {
  validation_require "$1" "_firewall_flush_table:table name[1]"

  sudo_run nft flush set ip global $1
}

_firewall_update_table() {
  validation_require "$1" "_firewall_update_table:table name[1]"
  validation_require "$2" "_firewall_update_table:IP address[2]"

  sudo_run nft add element ip global $1 { $2 }
}

_firewall_update_table_from_file() {
  _file_has_contents $2 || {
    log_warn "file is empty: $2"
    return
  }

  local _table_name=$1
  [ -z "$_table_name" ] && _table_name=$(basename $(dirname $2))_$(basename $2)

  _table_name=$(printf '%s' $_table_name | tr '/' '_' | tr '-' '_' | sed -e 's/\.[[:alnum:]]*$//')

  sudo_run nft flush set ip global $_table_name

  sudo_run sh -c "xargs -a $2 -d '\n' -n 5000 | sed -e 's/ /, /g' | xargs -I % nft add element ip global $_table_name { % }"
}

_firewall_check() {
  sudo_run nft -cf /usr/local/etc/walterjwhite/firewall/main.nft
}

_firewall_restart() {
  sudo_run nft -f /usr/local/etc/walterjwhite/firewall/main.nft
}
