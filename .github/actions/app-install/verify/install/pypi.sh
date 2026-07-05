#!/bin/sh

install_file=$1
if ! pip show "$install_file" >/dev/null 2>&1 && ! pip3 show "$install_file" >/dev/null 2>&1; then
  printf 'pypi package %s does not exist\n' "$install_file"
fi
