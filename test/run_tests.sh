#!/bin/sh

#
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"


_filter=""
_single_file=""
_verbose=0

while [ $# -gt 0 ]; do
  case "$1" in
  -f | --file)
    [ -z "$2" ] && {
      printf 'error: -f requires a filename\n' >&2
      exit 2
    }
    _single_file="$2"
    shift 2
    ;;
  -v | --verbose)
    _verbose=1
    shift
    ;;
  -h | --help)
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  -*)
    printf 'unknown option: %s\n' "$1" >&2
    exit 2
    ;;
  *)
    _filter="$1"
    shift
    ;;
  esac
done


if [ -n "$_single_file" ]; then
  _test_files="$_single_file"
else
  _test_dir="$SCRIPT_DIR"
  [ -n "$_filter" ] && _test_dir="$SCRIPT_DIR/$_filter"
  if [ ! -d "$_test_dir" ] && [ ! -f "$_test_dir" ]; then
    printf 'error: path not found: %s\n' "$_test_dir" >&2
    exit 2
  fi
  _test_files=$(find "$_test_dir" -name '*_test.sh' -type f | sort)
fi

if [ -z "$_test_files" ]; then
  printf 'no test files found under: %s\n' "${_test_dir:-$_single_file}" >&2
  exit 2
fi


_sep="------------------------------------------------------------"
printf '\n%-55s %s\n' "Test file" "Result"
printf '%-55s %s\n' "$_sep" "------"


_total_files=0
_failed_files=0
_failed_output=""

_list_file=$(mktemp)
printf '%s\n' "$_test_files" >"$_list_file"

while IFS= read -r _file; do
  [ -z "$_file" ] && continue

  _label=$(printf '%s' "$_file" | sed "s|${ROOT_DIR}/||")
  _total_files=$((_total_files + 1))

  _output=$(VERBOSE="$_verbose" sh "$_file" 2>&1)
  _rc=$?

  if [ "$_rc" -eq 0 ]; then
    printf '%-55s PASS\n' "$_label"
    if [ "$_verbose" -eq 1 ]; then
      printf '%s\n' "$_output" | grep '  ok  ' | sed 's/^/  /'
    fi
  else
    printf '%-55s FAIL\n' "$_label"
    _failed_files=$((_failed_files + 1))
    _failed_output="${_failed_output}
=== ${_label} ===
${_output}
"
  fi

done <"$_list_file"

rm -f "$_list_file"


_passed_files=$((_total_files - _failed_files))
printf '\n%d/%d test files passed' "$_passed_files" "$_total_files"

if [ "$_total_files" -eq 0 ]; then
  printf '\n'
elif [ "$_failed_files" -eq 0 ]; then
  printf ' -- all green\n'
else
  printf '\n'
fi

if [ -n "$_failed_output" ]; then
  printf '\n%s\n' "$_sep"
  printf 'FAILURES\n'
  printf '%s\n' "$_sep"
  printf '%s\n' "$_failed_output"
  exit 1
fi

exit 0
