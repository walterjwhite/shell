lib feature:./test

if [ $# -eq 0 ]; then
  _run_tests
else
  _load_libraries $(dirname "$1")

  for test_file_arg in "$@"; do
    _run_test_file "$test_file_arg"
  done
fi
