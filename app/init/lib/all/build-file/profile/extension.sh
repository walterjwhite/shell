_buildfile_inject_extension_cmd() {
  post_build_function=_buildfile_inject_extension_main lib_imports="$BUILDFILE_FULL_LIB extension.sh" _buildfile_inject_full $1
}

_buildfile_inject_extension_main() {
  printf '_extension_main "$@"\n' >>$buildfile_output_package_file
}
