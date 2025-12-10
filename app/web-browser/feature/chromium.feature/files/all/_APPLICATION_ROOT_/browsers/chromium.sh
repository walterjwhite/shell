lib extract.sh
lib git/github.sh
lib net/download.sh
lib sed.sh

BROWSER_CMD=$_CONF_WEB_BROWSER_CHROMIUM_CMD


case $_PLATFORM in
Linux | FreeBSD)
	_CONFIGURATION_DIRECTORY=~/.config/chromium
	;;
*)
	error "Unsupported platform: $_PLATFORM"
	;;
esac

_CONFIGURATION_DIRECTORY=~/.config/chromium

_BROWSER_NEW_INSTANCE() {
	local chromium_instance_dir=$_INSTANCE_DIRECTORY/.config/chromium

	mkdir -p $chromium_instance_dir/Default

	[ ! -e $_CONFIGURATION_DIRECTORY/Default/Preferences ] && error "$_CONFIGURATION_DIRECTORY/Default/Preferences does not exist"

	cp -R $_CONFIGURATION_DIRECTORY/Default/Preferences "$chromium_instance_dir/Default/"
	cp -R $_CONFIGURATION_DIRECTORY/Default/Extensions "$chromium_instance_dir/Default/" 2>/dev/null

	_INFO "Updating conf to use new instance dir"
	local home_directory_sed_safe=$(_sed_safe $HOME)
	local instance_dir_sed_safe=$(_sed_safe $chromium_instance_dir)

	find $_INSTANCE_DIRECTORY -type f ! -name '*.sqlite' -exec $_CONF_GNU_SED -i "s/$home_directory_sed_safe/$instance_dir_sed_safe/g" {} +

	mkdir -p $_INSTANCE_DIRECTORY/Downloads

	_SQLITE_DATABASE=$chromium_instance_dir/Default/History
	_QUERY="SELECT url,ROUND(LAST_VISIT_TIME/1000000) FROM urls WHERE url NOT LIKE 'chrome-extension://%' ORDER BY last_visit_time DESC"

	_browser_extensions
	[ -n "$_BROWSER_EXTENSIONS" ] && _browser_add_args "--load-extension=$_BROWSER_EXTENSIONS"
}

_browser_remotedebug() {
	local remotedebug
	if [ $_WEB_BROWSER_REMOTE_DEBUG -gt 0 ]; then
		remotedebug="=$_WEB_BROWSER_REMOTE_DEBUG"
	fi

	_browser_add_args "--remote-debugging-port${remotedebug}"

	[ "$_WEB_BROWSER_HEADLESS" ] && _browser_add_args --headless
}

_browser_private_window() {
	_browser_add_args --incognito
}

_BROWSER_HTTP_PROXY() {
	_browser_add_args "--proxy-server=http://${_WEB_BROWSER_HTTP_PROXY}"
}

_browser_socks_proxy() {
	_browser_add_args "--proxy-server=socks${_CONF_WEB_BROWSER_SOCKS_PROXY_VERSION}://$_WEB_BROWSER_SOCKS_PROXY"
}

_browser_extensions() {
	local extension_config extension_name extension_version
	for extension_config in $(cat $_CONFIGURATION_DIRECTORY/extensions); do
		_browser_extension $extension_config
	done
}

_browser_extension() {
	extension_name=$1

	case $extension_name in
	ublock-origin)
		_git_github_fetch_latest_artifact gorhill uBlock uBlock0_ .chromium.zip

		;;
	Browserpass)
		_git_github_fetch_latest_artifact browserpass browserpass-extension browserpass-github- .crx
		;;
	Ghostery)
		artifact_url_function=_ghostery_artifact_url _git_github_fetch_latest_artifact ghostery ghostery-extension ghostery-chromium- .zip

		;;
	*)
		_WARN "Unsupported extension: $extension_name"
		continue
		;;
	esac
}

_ghostery_artifact_url() {
	local version_without_v=$(printf '%s\n' "$3" | sed -e 's/^v//')
	_GITHUB_ARTIFACT_URL=https://github.com/$1/$2/releases/download/${3}/${4}${version_without_v}${5}
}

_browser_extension_load() {
	_browser_extension_download_extract $1 $2 $3 || {
		browser_extension_delete=1 _browser_extension_download_extract $1 $2 $3 || return 1
	}

	if [ -z "$_BROWSER_EXTENSIONS" ]; then
		_BROWSER_EXTENSIONS="$_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name"
	else
		_BROWSER_EXTENSIONS="$_BROWSER_EXTENSIONS,$_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name"
	fi
}

_browser_extension_download_extract() {
	[ "$browser_extension_delete" ] && rm -f $_CONF_INSTALL_CACHE_PATH/$extension_name-$extension_version.crx.zip

	_download $1 ${2}-$3.crx.zip
	_extract $_CONF_INSTALL_CACHE_PATH/$extension_name-$extension_version.crx.zip $_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name
}

_browser_cleanup() {
	rm -rf /tmp/.org,chromium.*
}
