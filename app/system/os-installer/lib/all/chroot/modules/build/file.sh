file_type=d
file_path='file'

patch_file() {
  for d in $(_module_find ! -execdir test -f .usr_local_prefix \; -exec printf '%s\n' {} + | $GNU_GREP -Po '^.*\.patch/file' | sort -u); do
    rsync -lmrt $d/ /
  done

  for d in $(_module_find -execdir test -f .usr_local_prefix \; -exec printf '%s\n' {} + | $GNU_GREP -Po '^.*\.patch/file' | sort -u); do
    rsync -lmrt $d/ /usr/local
  done
}
