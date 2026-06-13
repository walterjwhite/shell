lib net/rclone.sh

cfg feature:.

_android_build_artifacts() {

  find . -type f -name "*.apk"
}

_rclone_publish_all _android_build_artifacts

