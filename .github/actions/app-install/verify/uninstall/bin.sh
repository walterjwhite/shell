#!/bin/sh

install_file=$1
if [ -e "$install_file" ]; then
  printf '%s exists, but should have been removed\n' "$install_file"
fi
