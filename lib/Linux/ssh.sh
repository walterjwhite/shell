_ssh_prepare_ssh_conf() {
  local _path=$1
  local _user=$2

  mkdir -p "$_path/.ssh/socket"
  chmod 700 "$_path/.ssh/socket"

  printf 'StrictHostKeyChecking no\n' >>"$_path/.ssh/config"

  _ssh_init_bastion_host "$_path"

  [ "$_user" = "root" ] && return

  if [ -e /root/.ssh ]; then
    log_info "copying host ssh -> $_path/.ssh"

    cp /root/.ssh/id* /root/.ssh/config /root/.ssh/known_hosts "$_path/.ssh"
  fi

  if [ -e /root/.config/walterjwhite/shell ]; then
    log_info "copying walterjwhite conf -> $_path/.config/walterjwhite/shell"

    rm -rf "$_path/.config/walterjwhite/shell" && mkdir -p "$_path/.config/walterjwhite"
    cp -r /root/.config/walterjwhite/shell "$_path/.config/walterjwhite/shell"
  else
    log_warn "no walterjwhite conf found"
    find /tmp -maxdepth 1
  fi

  chown -R "$_user:$_user" "$_path"
}

_ssh_init_bastion_host() {
  local _path=$1

  [ -z "$bastion_host" ] && return 1

  log_info "setting up SSH Bastion host: $_path"

  _ssh_bastion_host "$_path"
  _ssh_bastion_proxies "$_path"

  chmod 600 "$_path/.ssh/config"
}

_ssh_bastion_host() {
  local _path=$1

  log_info "setting up SSH Bastion host: $_path"

  printf 'Host host-proxy\n' >>"$_path/.ssh/config"
  printf ' Hostname %s\n' "$bastion_host" >>"$_path/.ssh/config"
  printf ' User root\n' >>"$_path/.ssh/config"
}

_ssh_bastion_proxies() {
  local _path=$1

  for bastion_hostname in $(printf '%s' "$bastion_hostnames" | sort -u); do
    _ssh_bastion_proxy "$_path"
  done
}

_ssh_bastion_proxy() {
  local _path=$1

  log_info "setting up SSH host proxy: $_path"

  printf 'Host %s\n' "$bastion_hostname" >>"$_path/.ssh/config"
  printf ' ProxyJump host-proxy:%s\n' "$bastion_port" >>"$_path/.ssh/config"
  printf ' User root\n' >>"$_path/.ssh/config"
}

_ssh_use_host_ssh_conf() {
  rm -rf "$target/tmp/HOST-SSH" && mkdir -p "$target/tmp"
  cp -R /root/.ssh "$target/tmp/HOST-SSH"
}
