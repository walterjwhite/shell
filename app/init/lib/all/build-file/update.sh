_buildfile_update_remove_commented_code() {
  $GNU_SED -i '/^[[:space:]]*#[^!]/d' $buildfile_output_package_file

  $GNU_SED -i '/^[[:space:]]*$/d' $buildfile_output_package_file
}

_buildfile_update_constants() {
  [ "$target_application_name" = "$APPLICATION_NAME" ] && {
    log_debug "bypassing update - do NOT update self"
    return 1
  }



  $GNU_SED -i 's|__TARGET_APP_PLATFORM_PATH__|$TARGET_APP_PLATFORM_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__TARGET_APP_PATH__|$TARGET_APP_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__TARGET_APP_CONFIG_PATH__|$TARGET_APP_CONFIG_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__TARGET_BIN_PATH__|$TARGET_BIN_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__TARGET_SBIN_PATH__|$TARGET_SBIN_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__APPLICATION_NAME__|$APPLICATION_NAME|g' $buildfile_output_package_file
  $GNU_SED -i 's|__APPLICATION_VERSION__|$APPLICATION_VERSION|g' $buildfile_output_package_file
  $GNU_SED -i 's|__APP_PLATFORM_PLATFORM__|$APP_PLATFORM_PLATFORM|g' $buildfile_output_package_file

  $GNU_SED -i 's|__APP_PLATFORM_PATH__|$TARGET_APP_PLATFORM_PATH|g' $buildfile_output_package_file
  $GNU_SED -i 's|__APP_PATH__|$TARGET_APP_PATH|g' $buildfile_output_package_file
}

_buildfile_replace_constants() {
  sed \
    -e "s|__TARGET_APP_PLATFORM_PATH__|$TARGET_APP_PLATFORM_PATH|g" \
    -e "s|__TARGET_APP_PATH__|$TARGET_APP_PATH|g" \
    -e "s|__TARGET_APP_CONFIG_PATH__|$TARGET_APP_CONFIG_PATH|g" \
    -e "s|__TARGET_BIN_PATH__|$TARGET_BIN_PATH|g" \
    -e "s|__TARGET_SBIN_PATH__|$TARGET_SBIN_PATH|g" \
    -e "s/__APPLICATION_NAME__/$APPLICATION_NAME/g" \
    -e "s/__APPLICATION_VERSION__/$APPLICATION_VERSION/g" \
    -e "s/__APP_PLATFORM_PLATFORM__/$APP_PLATFORM_PLATFORM/g" \
    -e "s|__APP_PLATFORM_PATH__|$TARGET_APP_PLATFORM_PATH|g" \
    -e "s|__APP_PATH__|$TARGET_APP_PATH|g"
}
