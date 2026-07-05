#!/bin/sh

install_file=$1
cmd_name=$(basename "$install_file")
if command -v "$cmd_name" >/dev/null 2>&1 || [ -e "$HOME/.cargo/bin/$cmd_name" ]; then
  printf 'rust package %s exists, but should have been removed\n' "$install_file"
fi
