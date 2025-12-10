#!/bin/sh

if [ -z "$_DNSTAP_FILE" ]; then
	_DNSTAP_FILE="-r /var/log/dnstap/dnstap.log"
fi

if [ -z "$_INCLUDE_SELF" ]; then
	_append "!/\"query_address\":\"127.0.0.1\"/"
fi
