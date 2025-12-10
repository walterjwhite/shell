_browser_add_args() {
	_BROWSER_ARGS="$_BROWSER_ARGS $*"
}

_web_browser_cleanup() {
	_export_history

	_WARN "Removing $_INSTANCE_DIRECTORY"

	rm -rf $_INSTANCE_DIRECTORY
}

_launch() {
	if [ -n "$_WEB_BROWSER_REMOTE_DEBUG" ]; then
		$BROWSER_CMD $_BROWSER_ARGS 2>&1 | $_CONF_GNU_GREP -m 1 --line-buffered -Po "ws://127.0.0.1:[\d]{3,6}/devtools/browser/[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}" \
			>>$_INSTANCE_DIRECTORY/remote
	else
		$BROWSER_CMD $_BROWSER_ARGS >/dev/null 2>&1
	fi

	wait
}

_browser_configure() {
	_INSTANCE_DIRECTORY=$(_MKTEMP_OPTIONS=d _mktemp)
	_WARN "Using $_INSTANCE_DIRECTORY"

	_defer _web_browser_cleanup
	_defer _browser_cleanup

	[ ! -e $_CONF_APPLICATION_LIBRARY_PATH/browsers/$_CONF_WEB_BROWSER_BROWSER.sh ] && _ERROR "Unsupported browser: $_CONF_WEB_BROWSER_BROWSER"

	. $_CONF_APPLICATION_LIBRARY_PATH/browsers/$_CONF_WEB_BROWSER_BROWSER.sh

	_ORIGINAL_HOME=$HOME

	_BROWSER_NEW_INSTANCE

	[ "$_WEB_BROWSER_PASSWORD_STORE" ] && {
		[ ! -e $_INSTANCE_DIRECTORY/.gnupg ] && ln -s $HOME/.gnupg $_INSTANCE_DIRECTORY/.gnupg
		[ ! -e $_INSTANCE_DIRECTORY/.password-store ] && ln -s $HOME/.password-store $_INSTANCE_DIRECTORY/.password-store
	}

	HOME=$_INSTANCE_DIRECTORY

	[ -n "$_WEB_BROWSER_REMOTE_DEBUG" ] && _browser_remote_debug
	[ -n "$_WEB_BROWSER_NEW_PRIVATE_WINDOW" ] && _browser_private_window
	[ -n "$_WEB_BROWSER_HTTP_PROXY" ] && _BROWSER_HTTP_PROXY && _save_history
	[ -n "$_WEB_BROWSER_SOCKS_PROXY" ] && _browser_socks_proxy && _save_history
}

_browser_cleanup() {
	:
}
