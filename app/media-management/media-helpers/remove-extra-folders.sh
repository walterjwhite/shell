#!/bin/sh

for p in $(find . -type d | grep jpeg$); do
	_parent=$(dirname $p)

	_contents=$(find $p -type l | wc -l)
	if [ "$_contents" -eq "0" ]; then
		rm -rf $p
	fi

	_INFO "$_parent"
	_INFO "move $p/* -> $_parent"

	printf '\n'
done
