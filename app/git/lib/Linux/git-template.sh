#!/bin/sh

_git_is_run_hooks() {
	_get_user_groups | grep '^users$' >/dev/null 2>&1
}

_get_user_groups() {
	groups $(whoami) | sed -e 's/^.*://' | tr ' ' '\n' | $_CONF_GNU_GREP -Pv '^$'
}
