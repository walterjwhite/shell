lib io/file.sh

__KERNEL_TYPE=d
__KERNEL_PATH=_kernel

_PATCH__KERNEL() {
	_require_file "$1"

	__kernel_source

	printf '# build a kernel targetted for this hardware only\nCPUTYPE?=native\n\n' >>/etc/make.conf

	__kernel_modules_conf $1
	__kernel_kernel_conf $1

	__kernel_build

	$_CONF_GNU_SED -i "s/Components src world kernel/Components src world/" /etc/freebsd-update.conf

	_INFO "kernel build complete"
}

__kernel_source() {
	_SYSTEM_VERSION=$(uname -r | sed -e "s/\-.*//")
	_SYSTEM_ARCHITECTURE=$(uname -m)

	_SYSTEM_CONFIGURATION=/usr/src/sys/$_SYSTEM_ARCHITECTURE/conf
	if [ ! -e $_SYSTEM_CONFIGURATION ]; then
		git clone -b releng/$_SYSTEM_VERSION --depth 1 https://git.freebsd.org/src.git /usr/src
	fi
}

__kernel_modules_conf() {
	if [ -e $1/modules ]; then
		grep -cq cpuctl $1/modules || {
			_WARN "Enabling CPU microcode update support by including cpuctl as a kernel module"
			printf 'cpuctl\n' >>$1/modules
		}

		printf 'MODULES_OVERRIDE=%s\n\n' "$($_CONF_GNU_GREP -Pvh '(^$|^#)' $1/modules | tr '\n' ' ')" >>/etc/make.conf
	fi
}

__kernel_kernel_conf() {
	cp $1/kernel $_SYSTEM_CONFIGURATION/custom
}

__kernel_build() {
	mkdir -p /tmp/kernel-build

	_INFO "Building $_SYSTEM_ARCHITECTURE kernel"

	cd /usr/src

	__kernel_build_do build
	__kernel_build_do install

	_kernel_output
}

__kernel_build_do() {
	make ${1}kernel KERNCONF=custom >/tmp/kernel-build/$1.out 2>/tmp/kernel-build/$1.err || {
		_kernel_output $1
		return 2
	}
}

_kernel_output() {
	if [ $# -gt 0 ]; then
		_WARN "$1 kernel failed"
		cat /tmp/kernel-build/$1.out /tmp/kernel-build/$1.err
	fi
}
