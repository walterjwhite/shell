_domain_blocks_strip() {
  $GNU_GREP -Pv "(^#.*$|^$|^localhost$)" | sed -e "s/\r//"
}

_domain_blocks_filter() {
  cat
}

_domain_blocks_install() {
  local blocklist_name=$(basename $0 | sed -e 's/\.sh//' -e 's/\.run//')
  log_info "updating $blocklist_name rules"

  local target_file=$conf_domain_blocks_blocklist/$blocklist_name
  mkdir -p $(dirname $target_file)

  curl --connect-timeout $conf_domain_blocks_curl_connect_timeout -s $1 | _domain_blocks_strip | _domain_blocks_filter | sort -u | sudo_run tee $target_file >/dev/null
}

_domain_blocks_aggregate() {
  mkdir -p $1

  find $1 -type f ! -name '.aggregate' -exec cat {} \; 2>/dev/null |
    $GNU_GREP -Pv "^(#|$)" |
    sort -u >$1/.aggregate
}
