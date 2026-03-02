clear_user_sessions() {
  who | awk {'print$1'} | sort -u | grep -v root |
    xargs -I % pkill -u %

  who | grep -v root | awk {'print$2'} | sort -u |
    xargs -I % pkill -t %
}
