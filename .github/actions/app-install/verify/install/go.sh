#!/bin/sh

install_file=$1
cmd_name=$(basename "$(printf '%s\n' "$install_file" | sed 's/@.*//; s/\/v[0-9]*$//')")
if ! command -v "$cmd_name" >/dev/null 2>&1 && [ ! -e "$HOME/go/bin/$cmd_name" ] && [ ! -e "/usr/local/go/bin/$cmd_name" ]; then
  printf 'go package %s does not exist\n' "$install_file"
fi
