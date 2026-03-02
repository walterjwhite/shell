_iostat_io() {
  zpool iostat -Hyqp $(_system_zfs_pool) 1 $conf_install_iostat_duration |
    awk {'print$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16'} |
    tr ' ' '+' |
    tr '\n' '+' |
    sed -e 's/+$//' |
    bc
}

_iostat_stat_ctime() {
  stat -s $1 | tr ' ' '\n' | grep st_ctime | sed -e 's/.*=//'
}
