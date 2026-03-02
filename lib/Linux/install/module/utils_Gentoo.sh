_utils_get_feature_name() {
  local _path=$1
  case $_path in
  *feature*)
    printf '%s' "$_path" | sed \
      -e 's/^.*\/feature\///' \
      -e 's/.feature\/.*//' \
      -e 's/^/./' \
      -e 's/\//./g'
    ;;
  *)
    printf ''
    ;;
  esac
  unset _path
}

_utils_portage_install_file() {
  local _portage_type=$1
  local _file=$2
  mkdir -p /etc/portage/$_portage_type
  cp $_file /etc/portage/$_portage_type/app.$target_application_name$(_utils_get_feature_name $_file)
  unset _portage_type _file
}

_utils_portage_uninstall_file() {
  local _portage_type=$1
  local _file=$2
  rm -f /etc/portage/$_portage_type/app.$target_application_name$(_utils_get_feature_name $_file)
  unset _portage_type _file
}

_utils_portage_is_installed() {
  local _portage_type=$1
  local _file=$2
  [ -e /etc/portage/$_portage_type/app.$target_application_name$(_utils_get_feature_name $_file) ]
  unset _portage_type _file
}
