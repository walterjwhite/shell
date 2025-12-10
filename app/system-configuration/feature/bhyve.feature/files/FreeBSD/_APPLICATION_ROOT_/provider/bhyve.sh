_bhyve_create() {
	_OPTIONS=""

	[ -n "$_VM_SIZE" ] && _OPTIONS="$_OPTIONS -s $_VM_SIZE"
	[ -n "$_VM_MEMORY" ] && _OPTIONS="$_OPTIONS -m $_VM_MEMORY"

	[ -n "$_VM_CPUS" ] && _OPTIONS="$_OPTIONS -c $_VM_CPUS"
	[ -n "$_VM_TEMPLATE" ] && _OPTIONS="$_OPTIONS -t $_VM_TEMPLATE"

	vm create $_VM_NAME $_OPTIONS
}

_bhyve_copy_conf() {
	cp -R $BHYVE_VM_TEMPLATES/$_VM_NAME/* /$BHYVE_VM_DIR/$_VM_NAME/

	mv /$BHYVE_VM_DIR/$_VM_NAME/vm-bhyve.conf /$BHYVE_VM_DIR/$_VM_NAME/$_VM_NAME.conf
}

_bhyve_image() {
	if [ -n "$_VM_ISO_FILENAME" ]; then
		[ ! -e "/$BHYVE_VM_DIR/.iso/$_VM_ISO_FILENAME" ] && vm iso $_VM_ISO_URL

		return
	fi

	_bhyve_cloud_image
}

_bhyve_cloud_image() {
	pkg install -y qemu-tools cdrkit-genisoimage
}

_bhyve_install() {
	export _VM_NAME _VM_ISO_FILENAME _VM_VERSION _VM_HOSTNAME _VM_IP_ADDRESS
	local _original_wd=$PWD

	cd /$BHYVE_VM_DIR/$_VM_NAME

	_INFO "Installing VM: $_VM_NAME"

	timeout -k $_BHYVE_KILL_BHYVE_TIMEOUT $_BHYVE_TIMEOUT ./install

	cd $_original_wd

	zap snap 30d $BHYVE_VM_DIR/$_VM_NAME

	unset _VM_ISO_FILENAME _VM_ISO_URL
}

_bhyve_provision() {
	for _VM in $(find $BHYVE_VM_TEMPLATES -maxdepth 1 -type d ! -name 'bhyve'); do
		_VM_NAME=$(basename $_VM)

		_INFO "Preparing VM: $_VM_NAME"

		if [ $(vm list | sed 1d | awk {'print$1'} | grep -c $_VM_NAME) -gt 0 ]; then
			_WARN "$_VM_NAME is already installed, aborting"
			continue
		fi

		_INFO "Reading conf for VM: $_VM_NAME"
		. $BHYVE_VM_TEMPLATES/$_VM_NAME/configuration

		_bhyve_create
		_bhyve_copy_conf

		_bhyve_image

		_bhyve_install
	done
}

_bhyve_init() {
	[ -n "$_BHYVE_INIT" ] && return 0

	BHYVE_VM_TEMPLATES=/usr/local/etc/walterjwhite/bhyve

	if [ ! -e $BHYVE_VM_TEMPLATES ]; then
		_WARN "$BHYVE_VM_TEMPLATES does not exist, aborting"
		return 1
	fi

	if [ ! -e ~/.ssh/authorized_keys ]; then
		_WARN "~/.ssh/authorized_keys does *NOT* exist, it is required to SSH into guests"
		return 1
	fi

	package_install $_CONF_SYSTEM_CONFIGURATION_BHYVE_REQUIRED_PACKAGES

	sysrc vm_enable=YES

	sysrc cloned_interfaces="bridge0 tap0"
	sysrc ifconfig_bridge0_name="${_BHYVE_INTERFACE}bridge"
	sysrc ifconfig_${_BHYVE_INTERFACE}bridge="addm ${_BHYVE_INTERFACE} addm tap0 up"

	sysrc -f /boot/loader.conf vmm_load=YES



	DEV_NAME=$(zfs list | grep ROOT | awk {'print$1'} | grep ROOT$ |
		sed -e "s/\/ROOT//" |
		head -1)

	BHYVE_VM_DIR=$DEV_NAME/bhyve

	sysrc vm_dir="zfs:$BHYVE_VM_DIR"

	zfs create $BHYVE_VM_DIR

	_BHYVE_KILL_BHYVE_TIMEOUT=1m
	_BHYVE_TIMEOUT=5m

	_BHYVE_VIRTIO_VERSION=0.1.266-1
	_BHYVE_VIRTIO_FILE_VERSION=0.1.266
	_BHYVE_VIRTIO_FILENAME=virtio-win-$_BHYVE_VIRTIO_FILE_VERSION.iso
	curl -o /$BHYVE_VM_DIR/$_BHYVE_VIRTIO_FILENAME https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-$_BHYVE_VIRTIO_VERSION/$_BHYVE_VIRTIO_FILENAME

	vm init

	vm switch create public 2>/dev/null
	vm switch add public $_BHYVE_INTERFACE 2>/dev/null

	_SSH_PUBLIC_KEY=$(cat ~/.ssh/authorized_keys)

	_BHYVE_INIT=1
}

system_configuration_bhyve() {
	_bhyve_init && _bhyve_provision
}
