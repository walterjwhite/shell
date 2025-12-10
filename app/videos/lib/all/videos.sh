lib clipboard.sh
lib git/data.app.sh

cfg git

_target() {
	date +%Y/%m/%d/%H.%M.%S
}

_video_fetch_metadata() {
	_INFO "Fetching metadata for: $_VIDEO_URL"

	_VIDEO_METADATA=$($_CONF_VIDEOS_YOUTUBE_DOWNLOAD_CMD --print "%(upload_date>%Y/%m/%d)s|%(duration>%H:%M:%S)s|%(title)s|%(uploader_id)s|%(uploader)s" "$_VIDEO_URL")
	_VIDEO_METADATA="$_VIDEO_URL|$_VIDEO_METADATA"

	_video_meta
}

_video_read_meta() {
	if [ -e $_VIDEO_FILE ]; then
		_DEBUG $_VIDEO_FILE
		_VIDEO_METADATA=$(head -1 $_VIDEO_FILE)
	fi
}

_video_meta() {
	[ -z "$_VIDEO_URL" ] && _VIDEO_URL=$(printf '%s' $_VIDEO_METADATA | cut -f1 -d'|')

	_VIDEO_KEY=$(printf '%s' $_VIDEO_URL | sed -e "s/^.*\=//")

	_VIDEO_DATE=$(printf '%s' $_VIDEO_METADATA | cut -f2 -d'|')
	_VIDEO_DURATION=$(printf '%s' $_VIDEO_METADATA | cut -f3 -d'|')
	_VIDEO_TITLE=$(printf '%s' $_VIDEO_METADATA | cut -f4 -d'|')
	_VIDEO_UPLOADER_ID=$(printf '%s' $_VIDEO_METADATA | cut -f5 -d'|')
	_VIDEO_UPLOADER_NAME=$(printf '%s' $_VIDEO_METADATA | cut -f6 -d'|')

	_INFO "$_VIDEO_URL - $_VIDEO_TITLE @ $_VIDEO_DURATION ($_VIDEO_DATE:$_VIDEO_UPLOADER_ID:$_VIDEO_UPLOADER_NAME)"
}

_videos_git() {
	_git_save "$_ACTION - $_VIDEO_KEY" "$@"
}

_videos_clipboard_get() {
	_VIDEOS_URL=$(_clipboard_get | sed -e 's/&.*$//')
}
