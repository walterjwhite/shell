
_filter_files() {
  local check_dirs
  check_dirs="$*"

  awk -v target="$target_platform" \
    -v check_str="$check_dirs" '
  BEGIN {
    split(check_str, arr, " ")
    for (i in arr) watched_dirs[arr[i]] = 1
  }
  {
    is_valid = 1
    
    n = split($0, parts, "/")

    for (i = 1; i < n; i++) {
      segment = parts[i]
      
      if (segment in watched_dirs) {
        
        next_segment = parts[i+1]
        
        if (next_segment != "all" && next_segment != target) {
          is_valid = 0
          break # Stop checking this path, it is bad
        }
      }
    }

    if (is_valid) print $0
  }' | sort -r
}
