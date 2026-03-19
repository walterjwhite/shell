_zfs_system_pool() {
  zfs list -H | awk {'print$1'} | grep ROOT$ | sed -e 's/\/ROOT//'
}

_iostat_io() {
  zpool iostat -Hyqp $(_zfs_system_pool) 1 $conf_install_iostat_duration |
    awk {'print$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16'} |
    tr ' ' '+' |
    tr '\n' '+' |
    sed -e 's/+$//' |
    bc
}

_iostat_ctime() {
  stat -c%W $1
}

_iostat_ctime_many() {
  stat -c '%W %n'
}
