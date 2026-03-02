cfg git

_git_system_conf() {
  log_warn "system conf: $1 | $2 | $conf_git_mirror"
  mkdir -p $2/root/.data/install

  [ -e $2/root/.config/walterjwhite/shell ] && {
    log_warn "configuration already exists, skipping"
    return
  }

  mkdir -p $2/root/.config/walterjwhite/shell

  git archive --remote $conf_git_mirror/data/$1/root/configuration.git $os_installer_configuration_branch walterjwhite-conf/shell |
    tar xp -C $2/root/.config/walterjwhite/shell --transform='s|^walterjwhite-conf/shell/||'
}
