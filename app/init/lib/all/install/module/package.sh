lib install

#
package_install() {
  _install_filter_file_callback "$1" _package_install_new_only
}

package_uninstall() {
  _install_uninstall_filter_file_callback "$1" _package_uninstall_do
}
