#!/bin/sh

for p in $(find by-time by-tag -type d | grep converted$); do
	_parent=$(dirname $p)

	_contents=$(find $p -type l | wc -l)
	if [ "$_contents" -eq "0" ]; then
		rm -rf $p
	fi

	_INFO "$_parent"
	_INFO "move $p/* -> $_parent"
	mv -i $p/* $_parent

	printf '\n'
done
