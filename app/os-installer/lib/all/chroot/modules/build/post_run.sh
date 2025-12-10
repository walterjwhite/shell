_PATCH_POST_RUN() {
	local post_run_conf
	for post_run_conf in $@; do
		cd $OS_INSTALLER_SYSTEM_WORKSPACE

		. $post_run_conf
	done
}

_post_run_post() {
	_post_run_restore_ssh
}

_post_run_restore_ssh() {
	_DETAIL "Restoring SSH configuration (if applicable)"

	[ -e /root/.ssh.restore ] && _post_run_restore_ssh_do /root

	[ ! -e /home ] && return

	for s in $(find /home -type d -depth 2 -name '.ssh.restore'); do
		_post_run_restore_ssh_do $(dirname $s)
	done
}

_post_run_restore_ssh_do() {
	_WARN "Removing setup .ssh with .ssh.restore [$1]"
	rm -rf $1/.ssh
	mv $1/.ssh.restore $1/.ssh
}
