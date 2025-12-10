
_download() {
	mkdir -p $_CONF_CACHE_PATH

	local _cached_filename
	if [ $# -gt 1 ]; then
		_cached_filename="$2"
	else
		_cached_filename=$(basename $1 | sed -e 's/?.*$//')
	fi

	_DOWNLOADED_FILE=$_CONF_CACHE_PATH/$_cached_filename
	[ -z "$_NO_CACHE" ] && {
		[ -e $_DOWNLOADED_FILE ] && {
			_DETAIL "$1 already downloaded to: $_DOWNLOADED_FILE"
			return
		}
	}

	if [ -z "$_DOWNLOAD_DISABLED" ]; then
		_INFO "Downloading $1 -> $_DOWNLOADED_FILE"
		curl $_CURL_OPTIONS -o $_DOWNLOADED_FILE -s -L "$1"
	else
		_continue_if "Please manually download: $1 and place it in $_DOWNLOADED_FILE" "Y/n"
	fi
}

_download_install_file() {
	_WARN_ON_ERROR=1 _require "$1" "1 (_download_install_file) target filename" || return 1

	[ -z $_INSTALL_FILE_CHMOD ] && _INSTALL_FILE_CHMOD=444

	_INFO "Installing $_DOWNLOADED_FILE -> $1"
	_sudo mkdir -p $(dirname $1)
	_sudo cp $_DOWNLOADED_FILE $1
	_sudo chmod $_INSTALL_FILE_CHMOD $1

	unset _DOWNLOADED_FILE _INSTALL_FILE_CHMOD

	[ -e $1 ] || _WARN "failed to install file to: $1"
}

_verify() {
	[ -z "$_HASH_ALGORITHM" ] && _HASH_ALGORITHM=512

	shasum -a $_HASH_ALGORITHM -c $1 >/dev/null 2>&1
}
