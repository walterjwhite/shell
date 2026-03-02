lib install/rust.sh

rust_path=rust
patch_rust() {
  _module_find_filtered_callback _RUST_INSTALL
}
