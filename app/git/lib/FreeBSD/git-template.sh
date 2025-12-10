#!/bin/sh

_git_is_run_hooks() {
	_get_user_groups | grep '^video$' >/dev/null 2>&1
}

_get_user_groups() {
	pw usershow -P -n $(whoami) | grep Groups | awk {'print$2'} | tr ',' '\n'
}
