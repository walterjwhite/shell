_help_print() {
  if [ -e $2 ]; then
    log_info "$1:"

    cat $2
    printf '\n'
  fi
}

_help_print_and_exit() {
  _help_print 'system-wide options' $LIBRARY_PATH/install/help/default

  if [ "$APPLICATION_NAME" != "install" ]; then
    _help_print $APPLICATION_NAME $LIBRARY_PATH/$APPLICATION_NAME/help/default
    _help_print "$APPLICATION_NAME/$APPLICATION_CMD" $LIBRARY_PATH/$APPLICATION_NAME/help/$APPLICATION_CMD
  fi

  exit 0
}
