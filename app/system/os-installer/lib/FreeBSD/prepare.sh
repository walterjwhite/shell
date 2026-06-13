_enable_sshd() {
  [ -e $_ROOT/etc/ssh/ssh_host_ed25519_key ] && {
    log_warn "sSH Host Key already exists, skipping"
    return
  }

  log_warn "generating SSH Host Key + enabling SSHd"
  chroot $root sysrc sshd_enable=YES
  chroot $root service sshd keygen
  chroot $root sysrc hostname=os-installer

  mkdir -p $HOME/.ssh
  cat $_ROOT/etc/ssh/ssh_host_*_key.pub | sed -e 's/^/os-installer /' >>$HOME/.ssh/known_hosts

  cp /etc/ssh/sshd_config $_ROOT/etc/ssh/
}

_os_prepare() {
  mkdir -p $_ROOT/mnt/os

  mkdir -p $_ROOT/var/cache/pkg

  grep -cqm1 fusefs_load $_ROOT/boot/loader.conf || printf '# prepare-install-media - sshfs-fuse\nfusefs_load="YES"\n\n' >>$_ROOT/boot/loader.conf

  grep -cqm1 tmpfs $_ROOT/etc/fstab || {
    printf '# prepare-install-media - use tmpfs for /root/.data\ntmpfs /root/.data tmpfs rw,mode=1777 0 0\n' >>$_ROOT/etc/fstab
  }

}
