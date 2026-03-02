tty_disable() {
  $GNU_SED -i 's/^c/#c/' /etc/inittab
  _reload_init
}

tty_enable() {
  $GNU_SED -i 's/^#c/c/' /etc/inittab
  _reload_init
}

_reload_init() {
  kill -hup 1
}
