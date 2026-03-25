lib system.sh
lib time.sh

_data_app_save() {
  local _message="$1"
  shift

  if [ -n "$git_project_path" ]; then
    cd $git_project_path
  fi

  git add $@ 2>/dev/null
  git commit $@ -m "$_message"

  local _has_remotes=$(git remote | wc -l)
  if [ "$_has_remotes" -gt "0" ]; then
    git push
  fi
}

_data_app_init() {
  local _project_identifier=$APPLICATION_NAME

  [ -n "$1" ] && _project_identifier=$1

  git_project_path=$DATA_PATH/$_project_identifier
  system_id=$(_system_get_id)

  if [ -n "$system_id" ]; then
    git_project=data/$system_id/$USER/$_project_identifier
  else
    git_project=data-$_project_identifier
  fi

  if [ ! -e $git_project_path/.git ]; then
    log_detail "initializing git $conf_git_mirror/$git_project @ $git_project_path"
    time_timeout $conf_git_clone_timeout _data_app_init git clone "$conf_git_mirror/$git_project" $git_project_path || {
      [ -z "$warn_on_error" ] && exit_with_error "unable to initialize project"

      log_warn "clone failed, initialized empty project"
      git init $git_project_path
    }
  fi

  cd $git_project_path
  git pull
}
