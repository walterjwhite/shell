#!/bin/sh

_history_behind_remote() {
  local _remote=origin

  if [ $# -gt 0 ]; then
    _remote=$1
    shift
  fi

  git status >/dev/null 2>&1
  if [ $? -gt 0 ]; then
    exit_with_error "unable to check status of git, are you in a git work tree?"
  fi

  git_behind_remote=$(git rev-list HEAD..$_remote --count)
}
