system_enable() {
  tty_enable
  usb_enable
  setterm_on
}

system_disable() {
  clear_user_sessions

  tty_disable
  usb_disable

  setterm_off
}
