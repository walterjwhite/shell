lib crontab.sh

cfg cron

crontab_type=d
patch_crontab() {
  local crontabs_temp_path=$(_mktemp_options=d _mktemp_mktemp)

  _module_find_callback _crontab_do
  _crontab_users
}

_crontab_do() {
  local _crontabs_directory=$1
  local crontab_user=$(basename $_crontabs_directory)
  local crontab_user_file=$crontabs_temp_path/$crontab_user


  local crontab_path
  for crontab_path in $(find $_crontabs_directory -type f | sort -V); do
    printf '# %s\n' "$crontab_path" >>$crontab_user_file
    cat $crontab_path >>$crontab_user_file
  done

  chown $crontab_user:wheel $crontab_user_file
  unset _crontabs_directory crontab_user crontab_user_file crontab_path
}

_crontab_users() {
  local crontab_user_file crontab_user
  for crontab_user_file in $(find $crontabs_temp_path -type f | sort -u); do
    crontab_user=$(basename $crontab_user_file)

    log_info "updating $crontab_user crontab"
    _crontab_append $crontab_user $crontab_user_file

    rm -f $crontab_user_file
  done
}
