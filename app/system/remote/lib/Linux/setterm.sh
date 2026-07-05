setterm_off() {
  sudo_run term=linux setterm --blank=force </dev/tty1
}

setterm_on() {
  sudo_run term=linux setterm --blank=poke </dev/tty1
}
