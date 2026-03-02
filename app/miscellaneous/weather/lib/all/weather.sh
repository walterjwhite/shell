lib iostat.sh

_weather_fetch() {
  log_detail "fetching weather"
  rm -f $weather_report_file
  curl -s https://$WEATHER_URL -o $weather_report_file
}

_weather_is_expired() {
  weather_report_file=$APP_DATA_PATH/$weather_location.$WEATHER_VERSION
  mkdir -p $(dirname $weather_report_file)

  [ ! -e $weather_report_file ] && return 0

  local weather_report_creation_time=$(_iostat_ctime $weather_report_file)
  local now=$(date +%s)

  local weather_report_expiration_time=$(($weather_report_creation_time + $conf_weather_report_max_age))

  [ $weather_report_expiration_time -lt $now ]
}
