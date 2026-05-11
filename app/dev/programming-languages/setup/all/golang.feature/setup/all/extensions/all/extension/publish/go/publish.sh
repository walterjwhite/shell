lib net/rclone.sh

_go_build_artifacts() {
  case $PWD in
  */cmd/*)
    local expected_bin_name=$(basename $PWD)
    find ~/go/bin -type f -name "$expected_bin_name"
    :
    ;;
  *)
    :
    ;;
  esac
}

_rclone_publish_all _go_build_artifacts
