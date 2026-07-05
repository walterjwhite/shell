#!/bin/sh

install_file=$1
if [ ! -e "$install_file" ]; then
  printf '%s does not exist\n' "$install_file"
fi
