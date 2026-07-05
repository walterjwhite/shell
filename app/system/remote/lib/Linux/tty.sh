tty_disable() {
  sudo_run $GNU_SED -i 's/^c/#c/' /etc/inittab
  _reload_init
}

tty_enable() {
  sudo_run $GNU_SED -i 's/^#c/c/' /etc/inittab
  _reload_init
}

_reload_init() {
  sudo_run kill -hup 1
}
