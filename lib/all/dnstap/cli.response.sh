#!/bin/sh

for _ARG in $@; do
	case $_ARG in
	-f=*)
		_DNSTAP_FILE="-r ${_ARG#*=}"
		shift
		;;
	-a)
		_DNSTAP_FILE="$(find $_DNSTAP_LOG_PATH -type f | sed -e \"s/^/-r /g\" | tr '\n' ' ')"
		;;
	-c=*)
		_append "/\"query_address\":\"${_ARG#*=}\"/"
		;;
	-s)
		_INCLUDE_SELF=1
		;;
	*)
		echo "$_ARG was not understood"
		;;
	esac
done
