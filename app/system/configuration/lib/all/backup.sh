configuration_backup() {
  rm -rf "$APP_DATA_PATH/$provider_name"

  [ ! -e "$provider_path" ] && {
    log_debug "path does not exist: $provider_path"
    return 1
  }

  mkdir -p "$APP_DATA_PATH/$provider_name"
  tar_cd='-C'
  [ -d "$provider_path" ] && {
    [ -z "$provider_include" ] && {
      provider_include='.'
    }

    return 0
  }

  provider_configuration_dir=$(dirname "$provider_path")
  tar_cd="-C $provider_configuration_dir"

  provider_path=$(basename "$provider_path")
}

configuration_backup_post() {
  git add "$APP_DATA_PATH/$provider_name"
}

configuration_backup_default() {
  local tar_exclude=""
  if [ -n "$provider_exclude" ]; then
    tar_exclude=$(printf '%s' "$provider_exclude" | sed -e 's/ / --exclude /g' -e 's/^/--exclude /')
  fi

  tar -cp $tar_args $tar_cd "$provider_path" $tar_exclude $provider_include 2>/dev/null | tar -xp $tar_args -C "$APP_DATA_PATH/$provider_name"
  unset tar_cd
}

configuration_backup_sync() {
  git status >/dev/null 2>&1 || {
    log_warn "git configuration repository not setup for $USER"
    return 1
  }

  if [ $(git remote -v | wc -l) -eq 0 ]; then
    log_warn "no remotes setup"
    return 1
  fi

  gd && _stdin_continue_if "Continue synchronizing contents?" "Y/n" && {
    gcommit -am 'sync'
    gpush
  }
}
