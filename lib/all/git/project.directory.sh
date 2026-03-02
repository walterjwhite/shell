lib git/include.sh

_project_directory_get_project_directory() {
  git_project_path=$(git rev-parse --show-toplevel 2>/dev/null)
  local _status=$?
  if [ $_status -gt 0 ]; then
    unset git_project_path
    return $_status
  fi

  git_project_name=$(basename $git_project_path)

  return 0
}
