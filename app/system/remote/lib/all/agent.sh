agent_driver() {
  [ -n "$remote_agent_user" ] && {
    export sudo_user=$remote_agent_user
    target_home=$(getent passwd "$remote_agent_user" | cut -d: -f6)

    sudo_run env PATH="$target_home/.local/bin:$PATH" agent-driver "$@"
    return $?
  }

  agent-driver "$@"
}
