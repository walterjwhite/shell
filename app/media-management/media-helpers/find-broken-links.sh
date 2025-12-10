#!/bin/bash

for link in $(find /media/jpeg -type l -xtype l); do
	_link_basename=$(basename "$link" | sed -e "s/Link to //")
	_year=$(printf '%s' "$link" | $_CONF_GNU_GREP -Po "\/[\d]{4}\/" | sed -e "s/\///g")
	_originals=$(grep -i "$_link_basename" jpeg.lst | grep $_year)

	for _original in $(printf '%s' $_originals); do
		_is_broken=$(find $_original -type l -xtype l)
		if [ -z "$_is_broken" ]; then
			_INFO "copying original to replace broken link"

			_dir=$(dirname $_original)

			_INFO "mkdir -p fixed_links-2/$_dir"
			_INFO "cp $_original $_dir"

			break
		else
			_WARN "is broken:$_is_broken"
		fi
	done

done
