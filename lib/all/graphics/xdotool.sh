_xdotool_init() {
  :
}

_xdotool_move() {
  local _x=$1
  local _y=$2
  xdotool mousemove $_x $_y
}

_xdotool_key() {
  local _key=$1
  local _key_action=$2
  xdotool key${_key_action} "$_key"
}
