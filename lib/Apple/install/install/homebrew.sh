
_PACKAGE_BOOTSTRAP() {
	if [ ! -e $_CONF_INSTALL_HOMEBREW_CMD ]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

		grep -qm1 homebrew ~/.zprofile || printf 'eval "$(%s shellenv)"\n' "$_CONF_INSTALL_HOMEBREW_CMD" >>~/.zprofile
		eval "$($_CONF_INSTALL_HOMEBREW_CMD shellenv)"

		return
	fi

	_WARN "Homebrew appears to already be installed"
}

_PACKAGE_INSTALL_DO() {
	brew install $@
}

_PACKAGE_UNINSTALL() {
	brew uninstall $@
}

_PACKAGE_BOOTSTRAP_UNINSTALL() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

	_sudo rm -rf /opt/homebrew
}

_PACKAGE_UPDATE() {
	brew update
	brew upgrade $@
}

_PACKAGE_IS_INSTALLED() {
	brew ls --versions "$1" >/dev/null
	if [ $? -gt 0 ]; then
		return 1
	fi

	brew outdated "$1" >/dev/null
}

