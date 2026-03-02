#!/bin/sh

lib include.sh
lib ./init/runtime.sh
lib logging

cfg ./init
cfg logging


trap _on_exit 0 1 2 3 4 6 15 EXIT INT

log_info 'walterjwhite init'
exec_wrap _mount_filesystems

exec_wrap modules_${_MODULES_IMPLEMENTATION}

_process_cmdline

exec_wrap _wait_for_device
exec_wrap _cryptsetup_open
exec_wrap _mount_root_volume

exec_wrap _runtime_ram
exec_wrap _runtime_overlay root
warn=1 exec_wrap _read_rw

exec_wrap _runtime_cleanup
exec_wrap _switch_root
