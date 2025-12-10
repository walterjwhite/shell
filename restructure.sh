#!/bin/sh

for o in all Apple FreeBSD Linux Windows; do
	for d in bin cfg help lib files setup; do
		for p in $(find . -type d -path "*/$o/$d"); do
			t=$(dirname $(dirname $p))/$d
			mkdir -p $t
			[ -e $t/$o ] && {
				mv $t/$o $t/defaults
				p=$t/defaults
			}

			git mv $p $t/$o
		done
	done
done
