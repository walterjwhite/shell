_split_file_data() {
  split -b $conf_transfer_file_size -d "$_DATA_FILENAME"
}

_split_file_data_sed() {
  local index=0
  local line=0
  local line_count=$(wc -l <$_DATA_FILENAME)
  while [ $line -lt $line_count ]; do
    local filename=$(printf '%02d' "$index")
    if [ $i -gt 0 ]; then
      sed "1,${line}d" $_DATA_FILENAME | head -$conf_transfer_file_lines >$filename
    else
      head -$conf_transfer_file_lines $_DATA_FILENAME >$filename
    fi

    line=$(($line + $conf_transfer_file_lines))
    index=$(($index + 1))
  done
}
