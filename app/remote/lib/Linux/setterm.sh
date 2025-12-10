_setterm_off() {
	TERM=linux setterm --blank=force </dev/tty1
}

_setterm_on() {
	TERM=linux setterm --blank=poke </dev/tty1
}
