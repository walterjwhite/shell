_git_setup_mirror() {
  local remote_mirror=$1
  shift

  git remote add origin $remote_mirror

  case $remote_mirror in
  *@*)
    local git_tmp_dir=$(_mktemp_options=d _mktemp_mktemp)
    git clone . --mirror $git_tmp_dir

    _git_setup_mirror_scp && return

    _git_setup_mirror_tar

    exit_defer rm -rf $git_tmp_dir
    ;;
  http://* | https://*)
    log_warn "unable to setup mirror"
    ;;
  *)
    git clone . --mirror $remote_mirror
    ;;
  esac
}

_git_setup_mirror_scp() {
  which scp >/dev/null 2>&1 && {
    scp -r $git_tmp_dir $remote_mirror
    return
  }
}

_git_setup_mirror_tar() {
  local ssh_target=${remote_mirror%%:*}
  local remote_path=${remote_mirror#*:}

  tar -C $git_tmp_dir -cf - . | ssh $ssh_target "mkdir -p $remote_path && tar -C $remote_path -xf -"
}
