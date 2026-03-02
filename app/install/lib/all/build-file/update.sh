_buildfile_update_remove_commented_code() {
  $GNU_SED -i '/^[[:space:]]*#[^!]/d' $buildfile_output_package_file

  $GNU_SED -i '/^[[:space:]]*$/d' $buildfile_output_package_file
}

_buildfile_update_constants() {
  case $buildfile_output_package_file in
  */artifacts/install/*)
    log_debug "bypassing update"
    return 1
    ;;
  *)
    log_debug "updating constants: $buildfile_output_package_file"
    ;;
  esac

  $GNU_SED -i "s|__LIBRARY_APPLICATION_PATH__|$LIBRARY_PATH/$target_application_name|g" $buildfile_output_package_file
  $GNU_SED -i "s|__LIBRARY_PATH__|$LIBRARY_PATH|g" $buildfile_output_package_file
  $GNU_SED -i "s/__APPLICATION_NAME__/$target_application_name/g" $buildfile_output_package_file
  $GNU_SED -i "s/__APPLICATION_VERSION__/$target_application_version/g" $buildfile_output_package_file
  $GNU_SED -i "s/__PLATFORM__/$APP_PLATFORM_PLATFORM/g" $buildfile_output_package_file
}

_buildfile_replace_constants() {
  sed -e "s|__LIBRARY_APPLICATION_PATH__|$LIBRARY_PATH/$target_application_name|g" \
    -e "s|__LIBRARY_PATH__|$LIBRARY_PATH|g" \
    -e "s/__APPLICATION_NAME__/$target_application_name/g" \
    -e "s/__APPLICATION_VERSION__/$target_application_version/g" \
    -e "s/__PLATFORM__/$APP_PLATFORM_PLATFORM/g"
}
