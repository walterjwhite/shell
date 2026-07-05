lib crontab.sh

cfg cron

_crontab_target_user() {
  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    printf 'root'
  else
    printf '%s' "$(id -un)"
  fi
}

crontab_install() {
  local crontab_sudo_user
  crontab_sudo_user=$(_crontab_target_user)

  crontab_uninstall

  local temp_crontab
  temp_crontab=$(_mktemp_mktemp)

  cp "$1" "$temp_crontab"

  $GNU_SED -i "s/$/ # app.$target_application_name/" "$temp_crontab"

  local _marked_content
  _marked_content=$(cat "$temp_crontab")
  printf '# app.%s\n\n%s\n' "$target_application_name" "$_marked_content" >"$temp_crontab"

  _crontab_append "$crontab_sudo_user" "$temp_crontab"
  rm -f "$temp_crontab"
}

crontab_uninstall() {
  local crontab_sudo_user
  crontab_sudo_user=$(_crontab_target_user)

  local temp_crontab
  temp_crontab=$(_mktemp_mktemp)

  _crontab_remove "$temp_crontab"
  _crontab_write "$crontab_sudo_user" "$temp_crontab"
  rm -f "$temp_crontab"
}

_crontab_remove() {
  _crontab_get "$(_crontab_target_user)" "$1"

  $GNU_SED -i '/^$/d' "$1"

  $GNU_SED -i "/# app.$target_application_name/d" "$1"
}

crontab_is_installed() {
  local crontab_sudo_user
  crontab_sudo_user=$(_crontab_target_user)

  local temp_crontab
  temp_crontab=$(_mktemp_mktemp)

  _crontab_get "$crontab_sudo_user" "$temp_crontab"

  grep -qm1 "# app.$target_application_name" "$temp_crontab"
  rm -f "$temp_crontab"
}
