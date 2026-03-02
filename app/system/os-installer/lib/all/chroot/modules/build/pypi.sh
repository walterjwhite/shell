lib install/pypi.sh

pypi_path=pypi
patch_pypi() {
  _module_find_filtered_callback _PYPI_INSTALL
}
