_ydotool_init() {
  export YDOTOOL_SOCKET=/tmp/.ydotool_socket
}

_ydotool_move() {
  local _x=$1
  local _y=$2
  ydotool mousemove -x $_x -y $_y
}

_ydotool_key() {
  local _key_name=$1
  local _key_action_name=$2
  local key
  local key_action

  case $_key_name in
  ctrl)
    key=17
    ;;
  *)
    exit_with_error "unmapped key: $_key_name"
    ;;
  esac
  case $_key_action_name in
  down)
    key_action=1
    ;;
  up)
    key_action=0
    ;;
  *)
    exit_with_error "unmapped key action: $_key_action_name"
    ;;
  esac

  ydotool key "$key:$key_action"
}
