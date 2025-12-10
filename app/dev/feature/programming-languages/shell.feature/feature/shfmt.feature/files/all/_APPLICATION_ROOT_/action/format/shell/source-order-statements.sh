cfg .

_NO_EXEC=1

if [ "$#" -eq 0 ]; then
	SHELL_PATH=.
else
	SHELL_PATH="$*"
fi

shell_find | xargs -P$_CONF_DEV_FORMAT_PARALLEL -I _F sh-app-fmt _F
