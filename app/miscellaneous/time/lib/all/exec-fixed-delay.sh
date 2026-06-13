_time_exec_fixed_delay() {
  validation_require "$_FUTURE_DATE_TIME" "_FUTURE_DATE_TIME -dt"
  validation_require "$_FORMAT" _FORMAT

  current_epoch=$(date +%s)
  target_epoch=$(date $conf_date_options "$_FORMAT" "$_FUTURE_DATE_TIME" +%s)
  _delay=$(($target_epoch - $current_epoch))
}
