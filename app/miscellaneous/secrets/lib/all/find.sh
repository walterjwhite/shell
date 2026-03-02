secrets_find_file() {
  local directory=$1
  shift

  local extension=$1
  shift

  cd $directory

  grep_keywords=$(printf '%s' "$*" | tr ' ' '|')

  set -f
  find . -type f ! -path '*/.git/*' -name "*.$extension" $(printf '%s\n' "$@" | tr ' ' '\n' | sed -e 's/^/-ipath \*/' -e 's/$/\* /' | tr '\n' ' ' | sed -e 's/ $/\n/') |
    sed -e 's/^\.\///' -e "s/\.$extension\$//" | sort -u | $GNU_GREP -P --color "($grep_keywords)"
  set +f
}
