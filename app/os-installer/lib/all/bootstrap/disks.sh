_select_disk() {
	_require "$_CONF_OS_INSTALLER_DEV_NAME_MAP" _CONF_OS_INSTALLER_DEV_NAME_MAP

	local device_serial_number=$(_disk_serial $_CONF_OS_INSTALLER_DISK_DEV)

	local device_serial_number_entry
	local device_serial_number_entry_key
	local device_serial_number_entry_value
	for device_serial_number_entry in $(printf '%s\n' $_CONF_OS_INSTALLER_DEV_NAME_MAP); do
		device_serial_number_entry_key=${device_serial_number_entry%%:*}
		device_serial_number_entry_value=${device_serial_number_entry#*:}

		if [ "$device_serial_number_entry_key" = "$device_serial_number" ]; then
			OS_INSTALLER_ZFS_POOL_NAME=z_${device_serial_number_entry_value}
			_CONF_OS_INSTALLER_DISK_DEV_ID=$device_serial_number_entry_key
			_CONF_OS_INSTALLER_DISK_DEV_NAME=$device_serial_number_entry_value

			_INFO "Using $_CONF_OS_INSTALLER_DISK_DEV [$OS_INSTALLER_ZFS_POOL_NAME|$_CONF_OS_INSTALLER_DISK_DEV_NAME]"

			_warn_if_using_failing_disk $device_serial_number_entry_value

			_CONF_OS_INSTALLER_MOUNTPOINT=$_CONF_OS_INSTALLER_MOUNTPOINT/$OS_INSTALLER_ZFS_POOL_NAME
			return
		fi
	done
}

_warn_if_using_failing_disk() {
	[ -z "$_CONF_OS_INSTALLER_FAILING_DEVS" ] && return

	local failing_dev
	local failing_dev_id
	for failing_dev in $(printf '%s\n' $_CONF_OS_INSTALLER_FAILING_DEVS); do
		failing_dev_id=$(printf '%s' $failing_dev | sed -e 's/:.*$//')
		if [ "$_CONF_OS_INSTALLER_DISK_DEV_NAME" == "$failing_dev_id" ]; then
			_WARN "using a failing device: $failing_dev"
			return 1
		fi
	done
}

_init_disk_backup() {
	git clone $_CONF_OS_INSTALLER_DISK_GIT_URL $_CONF_OS_INSTALLER_MOUNTPOINT/tmp/disk || _ERROR "Unable to clone $_CONF_OS_INSTALLER_DISK_GIT_URL"

	local opwd=$PWD
	cd $_CONF_OS_INSTALLER_MOUNTPOINT/tmp/disk

	mkdir -p $_CONF_OS_INSTALLER_DISK_DEV_NAME/activity

	_backup_disk_encryption_headers
	_backup_disk_smartctl_stats
	_backup_disk_layout

	_init_git_config

	git add $_CONF_OS_INSTALLER_DISK_DEV_NAME
	git commit $_CONF_OS_INSTALLER_DISK_DEV_NAME -m "Backup $_CONF_OS_INSTALLER_DISK_DEV_NAME"
	git push

	cd $opwd

	rm -rf /tmp/disk
}

_init_git_config() {
	[ -e ~/.gitconfig ] && return 0

	git config --global user.email "$(whoami)@$(hostname)"
	git config --global user.name "$(whoami)@$(hostname)"
}

_backup_disk_smartctl_stats() {
	local drive_smart_activity_file=$_CONF_OS_INSTALLER_DISK_DEV_NAME/activity/$(date +%Y/%m/%d-%H.%M.%S)
	mkdir -p $(dirname $drive_smart_activity_file)

	smartctl -a ${_CONF_OS_INSTALLER_DISK_DEV} |
		$_CONF_GNU_GREP -P '^[\s]*[\d]+ [\w-]{3,}' \
			>$drive_smart_activity_file
}

_zpool_import() {
	zpool import -NR $_CONF_OS_INSTALLER_MOUNTPOINT $OS_INSTALLER_ZFS_POOL_NAME
}
