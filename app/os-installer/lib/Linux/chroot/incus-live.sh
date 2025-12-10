_incus_live_pre() {
	incus profile show default >/dev/null 2>&1 || _ incus admin init --auto

	incus profile show default | grep -A3 root | grep -A2 -B1 'path: /' | grep -A2 -B1 'pool: default' | grep -qm1 'type: disk' || {
		_WARN "Adding disk to default profile"
		_ incus profile device add default root disk pool=default path=/

		return
	}

	_WARN "Default profile already contains disk device"
}

_incus_live() {
	[ "$_APPLICATION_CMD" = "_gentoo-installer-chroot" ] && {
		_WARN "Due to current limitations, this step *MUST* be performed on the live system"
		return
	}

	cd /tmp

	. $_INCUS_CONFIGURATION_FILE
	_INCUS_CONFIGURATION_FILE_PATH=$(dirname $_INCUS_CONFIGURATION_FILE)
	_CONTAINER_NAME=$(basename $_INCUS_CONFIGURATION_FILE_PATH | $_CONF_GNU_SED -e 's/\.incus//' -e 's/^[[:digit:]]\+\.//')
	_CONTAINER_PATH=/var/lib/incus/storage-pools/default/containers/$_CONTAINER_NAME/rootfs

	GENTOO_SYSTEM_NAME=$_CONTAINER_NAME
	incus config show $_CONTAINER_NAME >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		_DETAIL "Creating new instance [$_CONTAINER_NAME]"
		_ incus launch images:$GENTOO_CONTAINER_IMAGE $_CONTAINER_NAME
	else
		_WARN "Using existing instance [$_CONTAINER_NAME]"
	fi

	mkdir -p $_CONTAINER_PATH/tmp
	cp -R /root/.ssh $_CONTAINER_PATH/tmp/HOST-SSH

	_incus_live_install_app install

	_NO_COPY_CONF=1 _incus_live_install_app gentoo-installer

	local o_CONF_GENTOO_INSTALL_PATH=$_CONF_GENTOO_INSTALL_PATH
	_CONF_GENTOO_INSTALL_PATH=$_CONTAINER_PATH

	_ _prepare_chroot

	GENTOO_REPOSITORY_PREFIX=$_CONTAINER_PATH _ _setup_git
	_ _configure

	_ _write_system
	_ _portage_write_package_license
	_ _portage_system_use_flags

	_ _hardware
	_ _pre_chroot

	_incus_mount_kernel_src

	incus exec \
		--env container=lxc $_CONTAINER_NAME \
		_gentoo-installer-chroot

	if [ -e $_INCUS_CONFIGURATION_FILE_PATH/post-setup ]; then
		_INFO "running post-setup scripts for $_CONTAINER_NAME"

		local post_setup_script
		for post_setup_script in $(find $_INCUS_CONFIGURATION_FILE_PATH/post-setup -type f | sort); do
			_INFO "Running $post_setup_script"
			. $post_setup_script
		done
	fi

	_CONF_GENTOO_INSTALL_PATH=$o_CONF_GENTOO_INSTALL_PATH
}

_incus_mount_kernel_src() {
	[ -e /usr/src ] && {
		mkdir -p $_CONTAINER_PATH/usr/src
		mount --bind /usr/src $_CONTAINER_PATH/usr/src

		_defer _incus_umount_kernel_src
	}
}

_incus_umount__KERNEL_src() {
	umount $_CONTAINER_PATH/usr/src
}

_incus_live_install_app() {
	_INFO "Installing $1 in container"
	mkdir -p $_CONTAINER_PATH/root/.config/walterjwhite/shell

	[ -z "$_NO_COPY_CONF" ] &&
		cp ~/.config/walterjwhite/shell/$1 $_CONTAINER_PATH/root/.config/walterjwhite/shell

	_PRESERVE_LOG=1 _ROOT=$_CONTAINER_PATH app-install $1
}

_incus_live_start() {
	rc-service incus status | grep -cqm1 started && return

	rc-service incus start && sleep 1

	_defer _incus_live_stop
}

_incus_live_stop() {
	rc-service incus stop
}
