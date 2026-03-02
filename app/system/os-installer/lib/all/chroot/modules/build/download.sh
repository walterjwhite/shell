lib extract.sh
lib net/download.sh

patch_download() {
  mkdir -p /tmp/downloads
  _module_find_callback _do_download
}

_do_download() {
  . $1

  _download_fetch $uri
  local _output=/tmp/downloads/$(basename $download_file)

  cp $download_file $_output
  if [ -n "$signature" ]; then
    sha256 -c $signature $_output 2>/dev/null
    if [ $? -eq 0 ]; then
      printf '\tOK\n'
    else
      printf '\tFAIL\n'
    fi
  fi

  _extract_extract $_output
}
