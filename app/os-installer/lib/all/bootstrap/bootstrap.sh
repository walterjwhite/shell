lib net/network.sh

_validate() {
	_require "$OS_INSTALLER_DISK_PASSPHRASE" OS_INSTALLER_DISK_PASSPHRASE

	local incorrect_prefix=$(printf '%s' "$_CONF_OS_INSTALLER_DISK_DEV_NAME" | grep -c ^z_)
	[ "$incorrect_prefix" -gt "0" ] && _CONF_OS_INSTALLER_DISK_DEV_NAME=$(printf '%s' "$_CONF_OS_INSTALLER_DISK_DEV_NAME" | sed -e "s/^z_//")

	_online
}

_init_chroot_net() {
	cp /etc/resolv.conf $_CONF_OS_INSTALLER_MOUNTPOINT/etc
}

_init_chroot_other() {
	[ -e /etc/hostid ] && cp /etc/hostid $_CONF_OS_INSTALLER_MOUNTPOINT/etc
}

_init_chroot_apps() {
	_ROOT=$_CONF_OS_INSTALLER_MOUNTPOINT _PRESERVE_LOG=1 _CHILD=1 app-install install os-installer
}

_init_chroot_app_conf() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/root/.config/walterjwhite
	cp -Rp /root/.config/walterjwhite/shell $_CONF_OS_INSTALLER_MOUNTPOINT/root/.config/walterjwhite/shell
	cp -Rp /root/.config/walterjwhite/shell $_CONF_OS_INSTALLER_MOUNTPOINT/tmp/CONFIG-WALTERJWHITE
}

_init_chroot_ssh() {
	cp /etc/ssh/sshd_config $_CONF_OS_INSTALLER_MOUNTPOINT/etc/ssh/sshd_config

	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/root/.ssh/socket $_CONF_OS_INSTALLER_MOUNTPOINT/tmp
	cp /root/.ssh/id* \
		/root/.ssh/authorized_keys \
		/root/.ssh/known_hosts \
		$_CONF_OS_INSTALLER_MOUNTPOINT/root/.ssh

	rm -rf $_CONF_OS_INSTALLER_MOUNTPOINT/tmp/HOST-SSH && mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/tmp
	cp -R /root/.ssh $_CONF_OS_INSTALLER_MOUNTPOINT/tmp/HOST-SSH
}

_init_chroot_system_git_workspace() {
	rm -rf $_CONF_OS_INSTALLER_MOUNTPOINT/$OS_INSTALLER_SYSTEM_WORKSPACE
	mkdir -p $(dirname $_CONF_OS_INSTALLER_MOUNTPOINT/$OS_INSTALLER_SYSTEM_WORKSPACE)
	cp -R $OS_INSTALLER_SYSTEM_WORKSPACE $_CONF_OS_INSTALLER_MOUNTPOINT/$OS_INSTALLER_SYSTEM_WORKSPACE
}

_write_system() {
	local system_id_file=$_CONF_OS_INSTALLER_MOUNTPOINT/usr/local/etc/walterjwhite/system
	mkdir -p $(dirname $system_id_file)

	printf '%s\n' $_CONF_OS_INSTALLER_SYSTEM_NAME >$system_id_file
	printf '%s\n' $_CONF_OS_INSTALLER_SYSTEM_REF >>$system_id_file
	printf '%s\n' $_CONF_OS_INSTALLER_SYSTEM_GIT >>$system_id_file
	git ls-remote $_CONF_OS_INSTALLER_SYSTEM_GIT -b $_CONF_OS_INSTALLER_SYSTEM_NAME | awk {'print$1'} >>$system_id_file

	printf 'Provision Date: %s\n' "$(date)" >>$system_id_file
}

_run_init() {
	OS_INSTALLER_EXEC_DIR=$_CONF_OS_INSTALLER_EXECUTION_LOG/$_CONF_OS_INSTALLER_DISK_DEV_NAME
	mkdir -p $OS_INSTALLER_EXEC_DIR
}
