patch_periodic() {
  _module_find -exec $APP_LIBRARY_PATH/bin/key_value /etc/periodic.conf {} \;
}
