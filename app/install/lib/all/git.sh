_is_registry_online() {
  git -c http.lowSpeedLimit=1 \
    -c http.lowSpeedTime=$conf_install_app_registry_timeout \
    -c core.sshCommand="ssh -o ConnectTimeout=$conf_install_app_registry_timeout -o ConnectionAttempts=1" \
    ls-remote "$registry_url" HEAD >/dev/null || {
    local status=$?


    return $status
  }
}

_set_registry() {
  if [ -n "$local_registry" ]; then
    registry_url=$optn_install_app_registry_git_url
    registry_path=${REGISTRY_PATH}.local
  else
    registry_url=$conf_install_app_registry_git_url
    registry_path=$REGISTRY_PATH
  fi
}
