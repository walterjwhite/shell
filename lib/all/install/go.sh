go_bootstrap() {
  _go_set_proxy

  _go_bootstrap_is_go_available || {
    _package_install_new_only $GO_PACKAGE
    _go_bootstrap_is_go_available || go_disabled=1
  }
}

_go_set_proxy() {
  [ -z "$http_proxy" ] && return

  git config --global http.proxy $http_proxy
  git config --global https.proxy $https_proxy

  exit_defer _go_clear_proxy
}

_go_clear_proxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

_go_bootstrap_is_go_available() {
  which go >/dev/null 2>&1
}

_go_walterjwhite_conf() {
  [ -e ./.build/go ] && . ./.build/go

  local _build_date=$(date +"%Y/%m/%d-%H:%M:%S")
  local _version=$(git branch --no-color --show-current)
  local _scm_id=$(git rev-parse HEAD)
  local _go_version=$(go version | awk {'print$3'})
  local _os_architecture=$(go version | awk {'print$4'})

  local _app_name_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.ApplicationName=$app_name"
  local _app_version_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.ApplicationVersion=$_version"
  local _scm_version_id_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.SCMId=$_scm_id"
  local _build_date_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.BuildDate=$_build_date"
  local _go_version_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.GoVersion=$_go_version"
  local _os_architecture_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.OSArchitecture=$_os_architecture"

  go_build_options="$go_build_options -X $_app_name_flag -X $_app_version_flag -X $_scm_version_id_flag -X $_build_date_flag -X $_go_version_flag -X $_os_architecture_flag"

  log_debug "build flags:"
  log_debug "$_app_name_flag"
  log_debug "$_app_version_flag"
  log_debug "$_scm_version_id_flag"
  log_debug "$_build_date_flag"
  log_debug "$_go_version_flag"
  log_debug "$_os_architecture_flag"
}

_go_install_do() {
  case $1 in
  *github.com/walterjwhite/*)
    _go_walterjwhite_conf
    ;;
  *)
    return 1
    ;;
  esac

  local go_install_path="$conf_install_go_path"
  local go_install_opts="$go_options -a -race -ldflags $go_build_options"

  (
    exec env GOPATH="$go_install_path" go install $go_install_opts "$1"
  ) || {
    log_warn "go install failed: $go_install_opts $@"
    log_warn "http_proxy: $http_proxy"
    log_warn "git  proxy: $(git config --global http.proxy)"
  }
}

_go_uninstall_do() {
  go uninstall "$@"
}
