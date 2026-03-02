_metadata_get() {
  validation_require "$1" METADATA_KEY_NAME

  grep $1 $APP_LIBRARY_PATH/.metadata | cut -f2 -d= | tr -d '"'
}

_metadata_load() {
  [ -f $APP_LIBRARY_PATH/.metadata ] || return 1

  . $APP_LIBRARY_PATH/.metadata
}
