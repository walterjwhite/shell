#!/bin/sh

install_file=$1
if command -v npm >/dev/null 2>&1 && npm list -g "$install_file" >/dev/null 2>&1; then
  printf 'npm package %s exists, but should have been removed\n' "$install_file"
fi
