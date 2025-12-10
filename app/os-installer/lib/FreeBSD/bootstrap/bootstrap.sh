
_init_chroot_apps() {
	local installed_file parent_dir
	for installed_file in $(cat $_CONF_LIBRARY_PATH/install/.files $_CONF_LIBRARY_PATH/os-installer/.files); do
		parent_dir=$_CONF_OS_INSTALLER_MOUNTPOINT/$(dirname $installed_file)
		mkdir -p $parent_dir

		cp $installed_file $parent_dir
	done
}
