_synced_has_uncommitted_work() {
  [ -n "$(git status --porcelain)" ] && return 1

  return 0
}

_synced_synced_with_remote() {
  local _branch_name=$1

  local _remote_hash=$(_synced_remote_hash $_branch_name)
  local _local_hash=$(git-head)

  [ "$_local_hash" = "$_remote_hash" ]
}

_synced_remote_hash() {
  [ -z "$git_type" ] && git_type=heads

  git ls-remote $(git remote -v | head -1 | awk {'print$2'}) | grep "refs/$git_type/${1}$" | cut -f1
}
