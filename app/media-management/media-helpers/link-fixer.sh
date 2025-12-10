#!/bin/bash

while read link; do
	_link_basename=$(basename "$link" | sed -e "s/Link to //")
	_year=$(printf '%s' "$link" | grep -Po "\/[\d]{4}\/" | sed -e "s/\///g")
	_original=$(grep -i "$_link_basename" jpeg.lst | grep $_year | head -4 | tail -1)

	if [ "$?" -gt "0" ]; then
		error "error processing:$link $_link_basename"
		continue
	fi

	printf '%s:%s\n' "$_link_basename" "$_original" >>/tmp/links

	_dir=$(dirname $_original)
	mkdir -p fixed_links-2/$_dir
	cp $_original fixed_links-2/$_dir
done <links.lst
