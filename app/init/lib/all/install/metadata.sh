_metadata_write_app() {
  local metadata_target_application_path="$TARGET_APP_PATH/.metadata"

  rm -f "$metadata_target_application_path"
  mkdir -p "$(dirname "$metadata_target_application_path")"

  #
  {
    printf 'APPLICATION_GIT_URL="%s"\n' "$git_target_application_url"
    printf 'APPLICATION_INSTALL_DATE="%s"\n' "$target_application_install_date"
    printf 'APPLICATION_VERSION="%s"\n' "$target_application_version"
    printf 'APPLICATION_BUILD_DATE="%s"\n' "$target_application_build_date"
  } >"$metadata_target_application_path"
}

_metadata_install_is_set() {
  local _path="${TARGET_APP_PATH:-$APP_PATH}"
  grep -hcqm1 "^$1=" "$_path/.metadata" 2>/dev/null
}

_metadata_install_append() {
  local _path="${TARGET_APP_PATH:-$APP_PATH}"

  case $_path in
  *$HOME*)
    mkdir -p "$_path"
    cat - >>"$_path/.metadata"

    return
    ;;
  esac

  sudo_run mkdir -p $_path
  cat - | sudo_run tee -a "$_path/.metadata" >/dev/null
}
