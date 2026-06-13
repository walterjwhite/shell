lib install

package_uninstall_path=package_uninstall
patch_package_uninstall() {
  _module_find_filtered_callback _package_uninstall_do
}
