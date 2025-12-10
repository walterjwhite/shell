lib time.sh

_CONSOLE_COMMENT() {
	cd $_CONF_APPLICATION_DATA_PATH

	local comment_path=$_CONSOLE_CONTEXT_ID/.comments/$(_time_decade)/$(date +%Y/%m.%B/%d)
	mkdir -p $comment_path

	local comment_filename=$(date +%H.%M.%S)

	$EDITOR $comment_path/$comment_filename

	git add $comment_path/$comment_filename &&
		git commit $comment_path/$comment_filename -m "comment - $comment_filename" &&
		git push
}
