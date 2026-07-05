#!/bin/sh

install_file=$1
if [ ! -e "$install_file" ] && [ ! -d "$install_file" ]; then
  printf 'feature %s directory not found\n' "$install_file"
fi
