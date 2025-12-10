_media_get_chromecast() {
	_INFO "Finding chromecast"

	local chromecasts=$(go-chromecast ls)
	if [ $(printf "$chromecasts\n" | wc -l) -gt 1 ]; then
		_WARN "Select device"
		printf '%s\n' "$chromecasts"

		_read_if 'Enter chromecast UUID' _CHROMECAST_UUID
	else
		_CHROMECAST_UUID=$(printf "$chromecasts" | sed -e 's/^.*uuid="//' -e 's/".*//')
	fi

	_require "$_CHROMECAST_UUID" _CHROMECAST_UUID
	_DETAIL "Using chromecast: $_CHROMECAST_UUID"
}

_media_chromecast_play() {
	for image_directory in $(_media_find_directories); do
		_media_play_slideshow "$image_directory"
		_media_play_videos "$image_directory"
	done
}

_media_find_directories() {
	find $_MEDIA_DIRECTORY -type d -exec sh -c \
		'[ "$(find "$1" -path "$1/*" -prune \( -type l -or -type f \) \
  \( -name '*.jpg' -or -name '*.mp4' \) \
  -exec sh -c "for file; do echo .; done" innersh \{\} + | wc -l)" -gt 0 ]' outersh {} \; -print | sort -V
}

_media_play_slideshow() {
	[ $(_media_find_images $1 | wc -l) -eq 0 ] && return 1

	_DETAIL "Playing slideshow for: $1"
	go-chromecast -u $_CHROMECAST_UUID slideshow --repeat=false $(_media_find_images $1) || _WARN "Error playing slideshow for: $1"
}

_media_find() {
	find "$1" -mindepth 1 -maxdepth 1 \( -type l -or -type f \) -name "*.$2" | sort -V
}

_media_find_images() {
	_media_find "$1" 'jpg'
}

_media_find_videos() {
	_media_find "$1" 'mp4'
}

_media_play_videos() {
	[ $(_media_find_videos $1 | wc -l) -eq 0 ] && return 1

	_DETAIL "Playing videos for: $1"
	for f in $(_media_find_videos $1); do
		go-chromecast -u $_CHROMECAST_UUID load $f || _WARN "Error playing video: $f"
	done
}
