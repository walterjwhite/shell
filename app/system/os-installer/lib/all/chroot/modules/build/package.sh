lib install

package_path=package
patch_package() {
  _module_find_filtered_callback _package_install_new_only
}
