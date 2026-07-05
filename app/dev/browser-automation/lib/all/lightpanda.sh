get_latest_lightpanda_version() {
  git -c http.lowSpeedLimit=1 \
    -c http.lowSpeedTime=$conf_install_app_registry_timeout \
    -c core.sshCommand="ssh -o ConnectTimeout=$conf_install_app_registry_timeout -o ConnectionAttempts=1" \
    ls-remote --refs https://github.com/lightpanda-io/browser.git refs/heads/main | cut -f1 | cut -c1-7
}

get_installed_lightpanda_version() {
  lightpanda version 2>&1
}
