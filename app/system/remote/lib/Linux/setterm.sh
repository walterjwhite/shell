setterm_off() {
  term=linux setterm --blank=force </dev/tty1
}

setterm_on() {
  term=linux setterm --blank=poke </dev/tty1
}
