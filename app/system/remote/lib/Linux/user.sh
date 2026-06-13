clear_user_sessions() {
  sudo_run sh -c "who | awk '{print$1}' | sort -u | grep -v root | xargs -I % pkill -u %"

  sudo_run "who | grep -v root | awk '{print$2}' | sort -u | xargs -I % pkill -t %"
}
