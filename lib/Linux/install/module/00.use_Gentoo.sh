lib install/module/utils_Gentoo.sh

use_bootstrap() {
  :
}

use_install() {
  local _name_suffix=$(_utils_get_feature_name $1)

  printf '# app.%s%s\n' $target_application_name "$_name_suffix" >>/etc/portage/make.conf
  printf 'USE="$USE %s"\n' "$(cat $1)" >>/etc/portage/make.conf
  unset _name_suffix
}

use_uninstall() {
  local _name_suffix=$(_utils_get_feature_name $1)

  $GNU_SED -i "s/ app.$target_application_name${_name_suffix}/ /" /etc/portage/make.conf
  unset _name_suffix
}

use_is_installed() {
  local _name_suffix=$(_utils_get_feature_name $1)

  grep -qm1 " # app.$target_application_name${_name_suffix}" /etc/portage/make.conf
  unset _name_suffix
}

use_enabled() {
  return 0
}

use_is_file() {
  return 0
}
