crontab_dcron_clear() {
  case $1 in
  root)
    sudo_user=$1 sudo_run crontab /etc/crontab
    ;;
  *)
    sudo_user=$1 sudo_run crontab -d
    ;;
  esac
}

crontab_dcron_get() {
  sudo_user=$1 sudo_run crontab -l | sudo_user=$1 sudo_run tee $2 >/dev/null 2>&1
}

crontab_dcron_write() {
  sudo_user=$1 sudo_run crontab $2
}
