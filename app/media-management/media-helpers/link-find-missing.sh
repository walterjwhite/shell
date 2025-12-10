#!/bin/bash

while read link; do

	_link_basename=$(basename "$link" | sed -e "s/Link to //")
	_year=$(printf '%s' "$link" | grep -Po "\/[\d]{4}\/" | sed -e "s/\///g")

	if [ -n "$_year" ]; then
		_fixed=$(grep -i "$_link_basename" fixed.lst | grep $_year | wc -l)
	else
		_fixed=$(grep -i "$_link_basename" fixed.lst | wc -l)
	fi

	if [ "$_fixed" -eq "0" ]; then
		printf 'missing:%s:%s\n' "$_year" "$_link_basename" >>missing-links.lst
	fi
done <links.lst
