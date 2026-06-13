_emerge_portage_use_git() {
  [ -e $APP_PLATFORM_ROOT/etc/portage/repos.conf/gentoo.conf ] && return

  _emerge_portage_setup_gentoo_git_workspace_conf

  [ -e $APP_PLATFORM_ROOT/var/db/repos/gentoo/.git ] && {
    log_detail "gentoo workspace already exists"
    return
  }

  _emerge_portage_setup_gentoo_git_workspace
}

_emerge_portage_setup_gentoo_git_workspace_conf() {
  rm -rf $APP_PLATFORM_ROOT/etc/portage/repos.conf && mkdir -p $APP_PLATFORM_ROOT/etc/portage/repos.conf
  printf '
  [DEFAULT]
  main-repo = gentoo

  [gentoo]
  location = /var/db/repos/gentoo
  sync-type = git
  sync-uri = https://github.com/gentoo-mirror/gentoo.git
  auto-sync = yes
  sync-git-verify-commit-signature = yes
  sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
  ' >$APP_PLATFORM_ROOT/etc/portage/repos.conf/gentoo.conf
}

_emerge_portage_setup_gentoo_git_workspace() {
  log_detail "cleaning $APP_PLATFORM_ROOT/var/db/repos/gentoo"
  rm -rf $APP_PLATFORM_ROOT/var/db/repos/gentoo/*

  log_warn "cloning gentoo repo @ /var/db/repos/gentoo"
  git clone --depth 1 https://github.com/gentoo-mirror/gentoo.git $APP_PLATFORM_ROOT/var/db/repos/gentoo
  log_warn "cloned gentoo repo @ /var/db/repos/gentoo"
}
