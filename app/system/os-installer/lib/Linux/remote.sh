_os_installer_prepare_remote() {
    scp /etc/systemd/resolved.conf $target_host:/etc/systemd/resolved.conf
    ssh $target_host systemctl restart systemd-resolved
}
