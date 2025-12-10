lib io/file.sh

_setup_git() {
	OS_INSTALLER_SYSTEM_WORKSPACE=$_CONF_OS_INSTALLER_MOUNTPOINT/tmp/os
	rm -rf $OS_INSTALLER_SYSTEM_WORKSPACE

	_setup_git_clone $_CONF_OS_INSTALLER_SYSTEM_NAME $OS_INSTALLER_SYSTEM_WORKSPACE
	cd $OS_INSTALLER_SYSTEM_WORKSPACE
}

_setup_git_clone() {
	mkdir -p $2

	git archive --remote $_CONF_OS_INSTALLER_SYSTEM_GIT $1 | tar xp -C $2 || {
		ping -c1 git >/dev/null 2>&1 || _WARN "Unable to ping git"
		ping -c1 google.com >/dev/null 2>&1 || _WARN "Unable to ping google"

		_ERROR "Error setting up git $_CONF_OS_INSTALLER_SYSTEM_GIT [$*]"
	}
	cd $2

	[ -e .import ] || {
		_DETAIL "No imports detected - $2"
		return
	}

	local git_import_contents=$(head -1 .import)

	_increase_indent
	_DETAIL "setting up import - $git_import_contents"

	_setup_git_clone $git_import_contents $OS_INSTALLER_SYSTEM_WORKSPACE/imports/$git_import_contents

	_decrease_indent
}
