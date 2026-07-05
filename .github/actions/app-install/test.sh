#!/bin/sh

set -e

PLATFORM=$1
BIN_PATH=$2

conf_log_level=${conf_log_level:-2}

curl -sSL \
  "https://raw.githubusercontent.com/walterjwhite/app-registry/refs/heads/main/install/${PLATFORM}/setup/bin/app-install" \
  -o /tmp/app-install
chmod +x /tmp/app-install
mv /tmp/app-install "${BIN_PATH}/app-install"

env conf_log_level="${conf_log_level}" "${BIN_PATH}/app-install" install

verify_install_type() {
  local type_name=$1
  local install_file=$2

  [ -z "$install_file" ] && return

  local script_path="$(dirname "$0")/verify/install/${type_name}.sh"
  if [ -x "$script_path" ]; then
    "$script_path" "$install_file"
  fi
}

verify_uninstall_type() {
  local type_name=$1
  local install_file=$2

  [ -z "$install_file" ] && return

  local script_path="$(dirname "$0")/verify/uninstall/${type_name}.sh"
  if [ -x "$script_path" ]; then
    "$script_path" "$install_file"
  fi
}

verify_installation() {
  local app_type_dir=$1
  if [ -d "$app_type_dir" ]; then
    for type_file in "$app_type_dir"/*; do
      [ -e "$type_file" ] || continue
      local type_name
      type_name=$(basename "$type_file")

      while read -r install_file; do
        verify_install_type "$type_name" "$install_file"
      done <"$type_file"
    done
  fi
}

verify_uninstallation() {
  local app_type_dir=$1
  if [ -d "$app_type_dir" ]; then
    for type_file in "$app_type_dir"/*; do
      [ -e "$type_file" ] || continue
      local type_name
      type_name=$(basename "$type_file")

      while read -r install_file; do
        verify_uninstall_type "$type_name" "$install_file"
      done <"$type_file"
    done
  fi
}

for app in $(find app -type d -maxdepth 2 ! -name install | sort -uV); do
  app_name=$(basename "$app")

  env conf_log_level="${conf_log_level}" "${BIN_PATH}/app-install" "$app_name" || {
    printf 'failed to install %s\n' "$app_name"
  }

  verify_installation "/usr/local/walterjwhite/$app/type"

  cp -r "/usr/local/walterjwhite/$app/type" "/tmp/app-$app_name.type"

  "${BIN_PATH}/app-uninstall" "$app_name"

  verify_uninstallation "/tmp/app-$app_name.type"

  rm -rf "/tmp/app-$app_name.type"
done
