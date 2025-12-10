lib io/file.sh
lib io/path.sh
lib sed.sh
lib time.sh

_git_in_project_base_path() {
	_in_path $_PROJECT_BASE_PATH
}

_git_in_user_home() {
	_in_path $HOME
}

_git_in_working_directory() {
	git status >/dev/null 2>&1
}

_git_relative_path() {
	_HOME_SED_SAFE=$(_sed_safe $(_readlink $HOME))
	_PROJECT_RELATIVE_PATH=$(pwd | sed -e "s/$_HOME_SED_SAFE\///")
}
