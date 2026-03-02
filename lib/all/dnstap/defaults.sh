#!/bin/sh

if [ -z "$dnstap_file" ]; then
  dnstap_file="-r /var/log/dnstap/dnstap.log"
fi

if [ -z "$dnstap_include_self" ]; then
  _write_append "\$3!=\"127.0.0.1\""
fi
