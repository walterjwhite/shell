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
    _write_append "\$3==\"${arg#*=}\""
    ;;
  -h=*)
    _write_append "substr(\$1,1,2) == \"${arg#*=}\""
    ;;
  -m=*)
    _write_append "substr(\$1,4,2) == \"${arg#*=}\""
    ;;
  -s)
    dnstap_include_self=1
    ;;
  *)
    echo "$arg was not understood"
    ;;
  esac
done
