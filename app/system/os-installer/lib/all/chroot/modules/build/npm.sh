lib install/module/npm.sh

npm_path=npm
patch_npm() {
  _module_find_filtered_callback _NPM_INSTALL
}
