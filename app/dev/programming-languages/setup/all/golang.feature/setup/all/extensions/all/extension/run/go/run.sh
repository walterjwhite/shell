lib io/file.sh

_runner_init() {
  local dev_notail=1
}

_runner_run() {
  local go_cmd_name=$(basename $PWD)
  ~/go/bin/$go_cmd_name "$@"
}
