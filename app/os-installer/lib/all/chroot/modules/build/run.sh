_PATCH_RUN() {
	local run_conf
	for run_conf in $@; do
		cd $OS_INSTALLER_SYSTEM_WORKSPACE

		. $run_conf || _WARN "Error running $_CONF_OS_INSTALLER_SYSTEM_NAME $run_conf"
	done
}
