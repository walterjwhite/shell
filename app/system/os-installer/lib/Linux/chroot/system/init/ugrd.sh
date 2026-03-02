init_ugrd() {
  mkdir -p /etc/portage/package.use /etc/portage/package.accept_keywords

  printf 'sys-kernel/installkernel ugrd\n' >>/etc/portage/package.use/installkernel

  [ -n "$_os_installer_zfs_pool_name" ] && {
    printf 'dev-python/zenlib **\n' >>/etc/portage/package.accept_keywords/ugrd
    printf 'dev-python/pycpio **\n' >>/etc/portage/package.accept_keywords/ugrd
    printf 'sys-kernel/installkernel **\n' >>/etc/portage/package.accept_keywords/ugrd
    printf 'sys-kernel/ugrd **\n' >>/etc/portage/package.accept_keywords/ugrd
  }

}
