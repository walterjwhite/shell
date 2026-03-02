lib crontab.sh

cfg cron

crontab_install() {
  local osudo_user=$sudo_user
  local sudo_user=root

  crontab_uninstall

  local temp_crontab=$(_mktemp_mktemp)

  cp $1 $temp_crontab

  $GNU_SED -i "s/$/ # app.$target_application_name/" $temp_crontab
  printf '\n' | tee -a $temp_crontab >/dev/null 2>&1

  $GNU_SED -i "1i # app.$target_application_name" $temp_crontab
  $GNU_SED -i "1i \\" $temp_crontab

  _crontab_append $sudo_user $temp_crontab
  rm -f $temp_crontab

  local sudo_user=$osudo_user
}

crontab_uninstall() {
  local osudo_user=$sudo_user
  local sudo_user=root

  local temp_crontab=$(_mktemp_mktemp)

  _crontab_remove $temp_crontab

  _crontab_write $sudo_user $temp_crontab
  rm -f $temp_crontab

  local sudo_user=$osudo_user
}

_crontab_remove() {
  _crontab_get $sudo_user $1

  $GNU_SED -i '/^$/d' $1

  $GNU_SED -i "/# app.$target_application_name/d" $1
}

crontab_is_installed() {
  local osudo_user=$sudo_user
  local sudo_user=root

  local temp_crontab=$(_mktemp_mktemp)

  _crontab_get $sudo_user $temp_crontab

  grep -qm1 "# app.$target_application_name" $temp_crontab
  rm -f $temp_crontab

  local sudo_user=$osudo_user
}
