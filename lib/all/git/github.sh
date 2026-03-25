lib net/download.sh

_github_latest_release() {
  [ -z "$4" ] && {
    get_latest_${1}_version
    return
  }

  curl -sL https://api.github.com/repos/$2/$3/releases/latest | jq -r "$4"
}

_github_fetch() {
  local download_url=$(curl -s https://api.github.com/repos/$1/$2/releases/latest | jq -r "$3")
  [ -z "$download_url" ] && {
      log_warn "no matching artifact found"
      return 1
  }

  _download_fetch "$download_url" $4-$5
}

_github_install_latest() {
  local function_name=$(printf '%s' $1 | tr '-' '_')

  local latest_version=$(_github_latest_release "$function_name" "$2" "$3" "$4")
  local installed_version=$(get_installed_${function_name}_version)

  [ "$installed_version" = "$latest_version" ] && {
    log_detail "$1 is already installed and up-to-date"
    return
  }

  if [ -z "$installed_version" ]; then
    log_detail "installing $1"
  else
    log_detail "updating $1"
  fi

  _github_fetch "$2" "$3" "$5" "$6" "$latest_version"

  [ -z "$7" ] && {
    log_warn "not installing $download_file"
    install_$function_name

    return
  }

  _install_file_chmod=755 _download_install_file $APP_PLATFORM_BIN_PATH/$7
}
