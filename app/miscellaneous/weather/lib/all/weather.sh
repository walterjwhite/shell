lib iostat.sh

_weather_fetch() {
  log_detail "fetching weather"
  rm -f "$weather_report_file"
  curl $conf_curl_flags -s "https://$WEATHER_URL" -o "$weather_report_file"
}

_weather_is_expired() {
  weather_report_file=$APP_DATA_PATH/$weather_location.$WEATHER_VERSION
  mkdir -p "$(dirname "$weather_report_file")"

  [ ! -e "$weather_report_file" ] && return 0

  __wr_creation_time=$(_iostat_ctime "$weather_report_file")
  __wr_now=$(date +%s)

  __wr_expiration_time=$((__wr_creation_time + conf_weather_report_max_age))

  [ "${__wr_expiration_time}" -lt "${__wr_now}" ]
}
