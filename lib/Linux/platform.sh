_sub_platform() {
	which lsb_release >/dev/null 2>&1 && {
		_SUB_PLATFORM=$(lsb_release -a | grep ID | cut -f2 -d: | tr -d '\t')
		return
	}

	[ -e $_ROOT/etc/os-release ] && {
		_SUB_PLATFORM=$(grep ^NAME= $_ROOT/etc/os-release | cut -f2 -d= | sed -e 's/"//g' -e 's/ Linux//')
	}

	[ -e $_ROOT/etc/gentoo-release ] && _SUB_PLATFORM=Gentoo
}
