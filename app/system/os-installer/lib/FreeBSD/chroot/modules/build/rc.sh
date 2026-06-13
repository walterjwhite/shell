patch_rc() {
  _module_find -exec $APP_PATH/bin/key_value /etc/rc.conf {} \;
}
