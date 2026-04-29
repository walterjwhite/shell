lib io/file.sh

android_build_debug() {
  validation_require "$1" "project_relative_path"

  project_relative_path=$1
  build_type=debug
  _android_build_artifact
  sudo_user=$conf_remote_android_user sudo_run $APP_LIBRARY_PATH/bin/android-build $project_relative_path $build_type $artifact_path

  _android_publish_artifact
}

android_build_release() {
  validation_require "$1" "project_relative_path"

  project_relative_path=$1
  build_type=release
  _android_build_artifact
  sudo_user=$conf_remote_android_user sudo_run $APP_LIBRARY_PATH/bin/android-build $project_relative_path $build_type $artifact_path

  _android_publish_artifact
}

_android_build_artifact() {
  project_name=$(basename "$project_relative_path")
  artifact_name="${project_name}-$build_type.apk"

  artifact_path=/tmp/$artifact_name
}

_android_publish_artifact() {
  file_require "$artifact_path"

  sudo_run chown $SUDO_USER:$SUDO_USER "$artifact_path"

  rclone copy "$artifact_path" $conf_remote_rclone_remote || {
    exit_with_error "failed to publish artifact to: $conf_remote_rclone_remote/$artifact_name"
  }

  log_info "published artifact to: $conf_remote_rclone_remote/$artifact_name"
}
