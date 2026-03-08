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

  local _app_name=$(basename $1 | sed -e 's/@.*//')
  local _build_date=$(date +"%Y/%m/%d-%H:%M:%S")
  local _version=$(git branch --no-color --show-current)
  local _scm_id=$(git rev-parse HEAD)
  local _go_version=$(go version | awk {'print$3'})
  local _os_architecture=$(go version | awk {'print$4'})

  local _app_name_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.ApplicationName=$_app_name"
  local _app_version_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.ApplicationVersion=$_version"
  local _scm_version_id_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.SCMId=$_scm_id"
  local _build_date_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.BuildDate=$_build_date"
  local _go_version_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.GoVersion=$_go_version"
  local _os_architecture_flag="${WALTERJWHITE_GO_APPLICATION_PACKAGE_PREFIX}.OSArchitecture=$_os_architecture"

  go_options="-ldflags"
  go_build_options="-X $_app_name_flag -X $_app_version_flag -X $_scm_version_id_flag -X $_build_date_flag -X $_go_version_flag -X $_os_architecture_flag"

  log_debug "build flags:"
  log_debug "$_app_name_flag"
  log_debug "$_app_version_flag"
  log_debug "$_scm_version_id_flag"
  log_debug "$_build_date_flag"
  log_debug "$_go_version_flag"
  log_debug "$_os_architecture_flag"
}

_go_install_do() {
  _go_is_installed $1 && {
    log_detail "$1 is already installed"
    return 0
  }

  case $1 in
  *github.com/walterjwhite/*)
    _go_walterjwhite_conf "$1"
    ;;
  *)
    log_debug "using standard go properties"
    ;;
  esac

  (
    if [ -n "$go_build_options" ]; then
      env GOPATH="$conf_install_go_path" CGO_ENABLED=1 go install -a -race $go_options "$go_build_options" "$1"
    else
      env GOPATH="$conf_install_go_path" CGO_ENABLED=1 go install -a -race $go_options "$1"
    fi
  ) || {
    log_warn "go install failed: env GOPATH='$conf_install_go_path' CGO_ENABLED=1 go install -a -race $go_options '$go_build_options' $1"
    log_warn "http_proxy: $http_proxy"
    log_warn "git  proxy: $(git config --global http.proxy)"
  }
}

_go_uninstall_do() {
  go uninstall "$@"
}

_go_is_installed() {
  local cmd_name=$(basename $(printf '%s\n' "$1" | sed -e 's/@.*//'))
  [ -e "$conf_install_go_path/bin/$cmd_name" ]
}

  

  
  
    

  
  
    

  
  
  
  
