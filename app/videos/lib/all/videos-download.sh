_video_download() {
	_video_read_meta

	_video_meta $_VIDEO_FILE >/dev/null 2>&1
	_EXTRACT_AUDIO=$(sed -n 2p $_VIDEO_FILE)
	_VIDEO_PROFILES=$(sed -n 3p $_VIDEO_FILE)

	_IS_PLAYLIST=$(printf '%s' "$_VIDEO_URL" | grep -c list=)

	[ -z "$INTERACTIVE" ] && _OPTIONS="--no-color -q"

	if [ -n "$_EXTRACT_AUDIO" ]; then
		_OPTIONS="$_OPTIONS -x --recode-video $_CONF_VIDEOS_AUDIO_FORMAT"
		_PREFIX=extracted
	fi

	if [ $_IS_PLAYLIST -eq 1 ]; then
		_OPTIONS="$_OPTIONS --restrict-filenames -o $_CONF_VIDEOS_DOWNLOAD_PATH/$_PREFIX/%(playlist)s/%(playlist_index)s-%(title)s-$_VIDEO_KEY.%(ext)s"
	else
		_OPTIONS="$_OPTIONS --restrict-filenames -o $_CONF_VIDEOS_DOWNLOAD_PATH/$_PREFIX/%(title)s-$_VIDEO_KEY.%(ext)s"
	fi

	_videos_download_setup_proxy

	_INFO "downloading $_VIDEO_URL - $_VIDEO_TITLE @ $_VIDEO_DURATION"
	_DEBUG "$_VIDEO_DATE:$_VIDEO_UPLOADER_ID:$_VIDEO_UPLOADER_NAME"

	$_CONF_VIDEOS_YOUTUBE_DOWNLOAD_CMD $_OPTIONS "$_VIDEO_URL" || _video_download_error

	if [ -n "$_EXTRACT_AUDIO" ]; then
		_video_download_extract_audio
		return
	fi

	_video_download_success
	_video_download_convert
}

_videos_download_setup_proxy() {
	[ -n "$http_proxy" ] && {
		_OPTIONS="$_OPTIONS --proxy $http_proxy"
		return
	}

	[ -n "$_VIDEOS_PROXY" ] && {
		_OPTIONS="$_OPTIONS --proxy $_VIDEOS_PROXY"
		return
	}

	return 1
}

_video_download_error() {
	_video_download_git error "download error"
	_ERROR "Error downloading video - $_VIDEO_KEY" $_status
}

_video_download_extract_audio() {
	_video_download_git extracted "download / extract"
}

_video_download_success() {
	_video_download_git downloaded "download"
	_INFO "Successfully downloaded $_VIDEO_URL - $_VIDEO_TITLE @ $_VIDEO_DURATION"
}

_video_download_git() {
	local video_target=$1/$(_target)
	mkdir -p $(dirname $video_target)

	git mv $_VIDEO_FILE $video_target || {
		git add $_VIDEO_FILE && git mv $_VIDEO_FILE $video_target || _ERROR "Error moving $_VIDEO_FILE -> $video_target"
	}

	_videos_git $_VIDEO_FILE $video_target
	unset _DOWNLOAD_ARGS
}

_video_download_convert() {
	if [ -z "$_VIDEO_PROFILES" ]; then
		return 1
	fi

	_VIDEO_MEDIA_FILE=$(find $_CONF_VIDEOS_DOWNLOAD_PATH -type f ! -name '.part' -name "*$_VIDEO_KEY*")
	_require "$_VIDEO_MEDIA_FILE" _VIDEO_MEDIA_FILE

	for _VIDEO_PROFILE in $_VIDEO_PROFILES; do
		_INFO "Converting video with $_VIDEO_PROFILE"

		local video_profile_name=$(printf $_VIDEO_PROFILE | tr '[:lower:]' '[:upper:]')

		local profile_video_format=$(env | grep "^_CONF_VIDEOS_PROFILE_${video_profile_name}_VIDEO_FORMAT=.*" | sed -e 's/^.*\=//')
		local profile_options=$(env | grep "^_CONF_VIDEOS_PROFILE_${video_profile_name}_OPTIONS=.*" | sed -e 's/^.*\=//')

		ffmpeg -i "$_VIDEO_MEDIA_FILE" $profile_options ${_VIDEO_MEDIA_FILE}-$_VIDEO_PROFILE.$profile_video_format
	done
}
