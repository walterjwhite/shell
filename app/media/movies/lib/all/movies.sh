lib git/data.app.sh

cfg git



_movies_git() {
  _data_app_save "$_ACTION - $_MOVIE_ID" "$@"
}

_movies_decade() {
  local _end_year=$(printf '%s' $_YEAR | head -c 4 | tail -c 1)
  local _event_decade_prefix=$(printf '%s' "$_YEAR" | $GNU_GREP -Po "[0-9]{3}")
  local _event_decade_start
  local _event_decade_end

  if [ "$_end_year" -eq "0" ]; then
    _event_decade_start=${_event_decade_prefix}
    _event_decade_start=$(printf '%s' "$_event_decade_start-1" | bc)

    _event_decade_end=${_event_decade_prefix}0
  else
    _event_decade_start=$_event_decade_prefix
    _event_decade_end=$_event_decade_prefix

    _event_decade_end=$(printf '%s' "$_event_decade_end+1" | bc)
    _event_decade_end="${_event_decade_end}0"
  fi

  _event_decade_start=${_event_decade_start}1

  decade=${_event_decade_start}-${_event_decade_end}
}
