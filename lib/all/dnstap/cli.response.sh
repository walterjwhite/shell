#!/bin/sh

for arg in $@; do
  case $arg in
  -f=*)
    dnstap_file="-r ${arg#*=}"
    shift
    ;;
  -a)
    dnstap_file="$(find $dnstap_log_path -type f | sed -e \"s/^/-r /g\" | tr '\n' ' ')"
    ;;
  -c=*)
    _write_append "/\"query_address\":\"${arg#*=}\"/"
    ;;
  -s)
    dnstap_include_self=1
    ;;
  *)
    echo "$arg was not understood"
    ;;
  esac
done
