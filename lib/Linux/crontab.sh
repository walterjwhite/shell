_CRONTAB_DCRON_CLEAR() {
	case $1 in
	root)
		_SUDO_USER=$1 _sudo crontab /etc/crontab
		;;
	*)
		_SUDO_USER=$1 _sudo crontab -d
		;;
	esac
}

_CRONTAB_DCRON_GET() {
	_SUDO_USER=$1 _sudo crontab -l | _SUDO_USER=$1 _sudo tee $2 >/dev/null 2>&1
}

_CRONTAB_DCRON_WRITE() {
	_SUDO_USER=$1 _sudo crontab $2
}
