get_latest_lightpanda_version() {
  git ls-remote --refs https://github.com/lightpanda-io/browser.git refs/heads/main | cut -f1 | cut -c1-7
}

get_installed_lightpanda_version() {
  lightpanda version 2>&1
}
