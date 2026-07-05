#!/bin/sh

install_file=$1
if command -v pip >/dev/null 2>&1 && pip show "$install_file" >/dev/null 2>&1; then
  printf 'pypi package %s exists, but should have been removed\n' "$install_file"
fi
if command -v pip3 >/dev/null 2>&1 && pip3 show "$install_file" >/dev/null 2>&1; then
  printf 'pypi package %s exists, but should have been removed\n' "$install_file"
fi
