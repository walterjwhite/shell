_NPM_BOOTSTRAP() {
	_NPM_BOOTSTRAP_IS_NPM_AVAILABLE || {
		_PACKAGE_INSTALL $NPM_PACKAGE
		_NPM_BOOTSTRAP_IS_NPM_AVAILABLE || NPM_DISABLED=1
	}

	_NPM_SETUP_PROXY
}

_NPM_BOOTSTRAP_IS_NPM_AVAILABLE() {
	which npm >/dev/null 2>&1
}

_NPM_INSTALL() {
	_NPM_BOOTSTRAP

	local npm_package
	for npm_package in "$@"; do
		_NPM_IS_INSTALLED $npm_package || _sudo npm install -s -g "$npm_package"
	done
}

_NPM_UNINSTALL() {
	_NPM_BOOTSTRAP

	_sudo npm uninstall -s -g "$@"
}

_NPM_IS_INSTALLED() {
	_NPM_BOOTSTRAP
	
	npm list -g $1 >/dev/null
}

_NPM_IS_FILE() {
	return 1
}

_NPM_SETUP_PROXY() {
	if [ -n "$http_proxy" ]; then
		_WARN "Configuring NPM to use an HTTP proxy: $http_proxy"

		npm config set proxy $http_proxy
		npm config set https-proxy $https_proxy

		_defer _NPM_CLEAR_PROXY
	fi
}

_NPM_CLEAR_PROXY() {
	_WARN "Reverting NPM HTTP proxy: $http_proxy"

	npm config rm proxy
	npm config rm https-proxy
}
