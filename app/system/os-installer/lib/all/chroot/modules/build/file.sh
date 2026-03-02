file_type=d
file_path='file'

patch_file() {
  _module_find -exec rsync -lmrt {}/ / \;
}
