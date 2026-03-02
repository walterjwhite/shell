lib install/go.sh

go_path=go
patch_go() {
  _module_find_filtered_callback _go_install_do
}
