lib io/file.sh

_setup_git() {
  _os_installer_system_workspace_path=${conf_os_installer_mountpoint}$conf_os_installer_system_workspace
  rm -rf $_os_installer_system_workspace_path

  _setup_git_clone $conf_os_installer_system_name $_os_installer_system_workspace_path
  cd $_os_installer_system_workspace_path
}

_setup_git_clone() {
  mkdir -p $2

  git archive --remote $conf_os_installer_system_git $1 | tar xp -C $2 || {
    exit_with_error "error setting up git $conf_os_installer_system_git [$*]"
  }
  cd $2

  [ -e .import ] || {
    log_detail "no imports detected - $2"
    return
  }

  local git_import_contents=$(head -1 .import)

  log_add_context $git_import_contents
  log_detail "setting up import"

  _setup_git_clone $git_import_contents $_os_installer_system_workspace_path/imports/$git_import_contents

  log_remove_context
}
