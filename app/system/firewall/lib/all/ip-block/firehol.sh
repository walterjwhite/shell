_firewall_ip_block_firehol() {
  local tmp_dir=$(_mktemp_options=d _mktemp_mktemp)
  local firewall_temp_file=$(_mktemp_mktemp)

  git clone --depth 1 https://github.com/firehol/blocklist-ipsets.git $tmp_dir >/dev/null 2>&1 || {
    log_warn "unable to clone https://github.com/firehol/blocklist-ipsets.git"
    return 1
  }

  find $tmp_dir -mindepth 1 -maxdepth 1 -type f -name '*.ipset' \
    -exec $GNU_GREP -Pvh '(^$|^#)' {} + | sort -u >>$firewall_temp_file

  rm -rf $tmp_dir

  _firewall_update_ip_block_update_firewall $firewall_temp_file
}
