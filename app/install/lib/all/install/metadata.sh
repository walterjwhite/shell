_metadata_write_app() {
  metadata_target_application_path=$APP_PLATFORM_LIBRARY_PATH/$target_application_name/.metadata

  rm -f $metadata_target_application_path

  {
    printf 'APPLICATION_GIT_URL="%s"\n' "$git_target_application_url"
    printf 'APPLICATION_INSTALL_DATE="%s"\n' "$target_application_install_date"
    printf 'APPLICATION_VERSION="%s"\n' "$target_application_version"
    printf 'APPLICATION_BUILD_DATE="%s"\n' "$target_application_build_date"
  } >>$metadata_target_application_path
}

_metadata_install_is_set() {
  $GNU_GREP -Phcqm1 "^$1=" $APPLICATION_METADATA_PATH 2>/dev/null
}

_metadata_install_append() {
  mkdir -p $(dirname $APPLICATION_METADATA_PATH)
  cat - >>$APPLICATION_METADATA_PATH
}

