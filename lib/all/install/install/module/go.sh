_GO_BOOTSTRAP() {
	_GO_BOOTSTRAP_IS_GO_AVAILABLE || {
		_PACKAGE_INSTALL $GO_PACKAGE
		_GO_BOOTSTRAP_IS_GO_AVAILABLE || GO_DISABLED=1
	}
}

_GO_BOOTSTRAP_IS_GO_AVAILABLE() {
	which go >/dev/null 2>&1
}

_GO_INSTALL() {
	_GO_BOOTSTRAP

	GO111MODULE=on GOPATH=$GO_INSTALL_PATH sudo_options="--preserve-env=GO111MODULE,GOPATH" _sudo go install $GO_OPTIONS "$@" || {
		_WARN "go install failed: $GO_OPTIONS $@"
		_WARN "  http_proxy: $http_proxy"
		_WARN "  git  proxy: $(git config --global http.proxy)"
	}
}

_GO_UPDATE() {
	:
}

_GO_UNINSTALL() {
	_sudo go uninstall "$@"
}

_GO_IS_INSTALLED() {
	_setup_type_is_installed "$1"
}

_GO_IS_FILE() {
	return 1
}
