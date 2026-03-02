lib io/file.sh
lib io/path.sh
lib time.sh

_git_in_project_base_path() {
  _path_in_path $GIT_PROJECT_BASE_PATH
}

_git_in_user_home() {
  _path_in_path $HOME
}

_git_in_working_directory() {
  git status >/dev/null 2>&1
}

_git_relative_path() {
  git_project_relative_path=$(pwd | sed -e "s|^$HOME/||")
}

_git_relative_path_in_worktree() {
  local worktree_path=$(git rev-parse --show-toplevel)
  pwd | sed -e "s|^$worktree_path/||"
}
