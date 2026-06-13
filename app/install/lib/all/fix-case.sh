_fix_case_targets() {
  _fix_case_collect_files

  [ "$#" -gt 0 ] && {
    _fix_case_user_provided_targets "$@"
    return
  }

  _fix_case_all
}

_fix_case_to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

_fix_case_to_upper() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]'
}

_fix_case_name_is_readonly_constant() {
  _name=$1

  while IFS= read -r _file; do
    [ -f "$_file" ] || continue

    if grep -Eqi "^[[:space:]]*readonly[[:space:]]+$_name=" "$_file" 2>/dev/null; then
      return 0
    fi
  done <"$_tmp_files"

  return 1
}

_fix_case_file_local_variables() {
  _file=$1
  _tab=$2

  awk -v tab="$_tab" '
    function count_cmdsub_opens(text, tmp, count) {
      tmp = text
      count = 0
      while (match(tmp, /\$\(/)) {
        count++
        tmp = substr(tmp, RSTART + RLENGTH)
      }
      return count
    }

    function count_paren_closes(text, tmp, count) {
      tmp = text
      count = 0
      while (match(tmp, /\)/)) {
        count++
        tmp = substr(tmp, RSTART + RLENGTH)
      }
      return count
    }

    /^[[:space:]]*local[[:space:]]+[A-Za-z_][A-Za-z0-9_]*/ {
      line = $0
      sub(/^[[:space:]]*local[[:space:]]+/, "", line)
      gsub(/"([^"\\]|\\.)*"/, "", line)
      gsub(/\047([^\\\047]|\\.)*\047/, "", line)

      field_count = split(line, fields, /[[:space:]]+/)
      in_assignment = 0
      cmdsub_depth = 0

      for (i = 1; i <= field_count; i++) {
        field = fields[i]
        if (field == "") {
          continue
        }

        if (in_assignment) {
          cmdsub_depth += count_cmdsub_opens(field)
          cmdsub_depth -= count_paren_closes(field)
          if (cmdsub_depth <= 0) {
            in_assignment = 0
            cmdsub_depth = 0
          }
          continue
        }

        if (field ~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
          print "variable" tab field
          continue
        }

        if (field ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
          split(field, parts, "=")
          if (parts[1] != "") {
            print "variable" tab parts[1]
          }

          value = substr(field, length(parts[1]) + 2)
          cmdsub_depth = count_cmdsub_opens(value) - count_paren_closes(value)
          if (cmdsub_depth > 0) {
            in_assignment = 1
          } else {
            cmdsub_depth = 0
          }
        }
      }
    }
  ' "$_file"
}

_fix_case_collect_files() {
  _collect_shell_files | sort -u >"$_tmp_files"
}

_fix_case_user_provided_targets() {
  for _name in "$@"; do
    case "$_name" in
    '' | *[!A-Za-z0-9_]* | [0-9]*)
      exit_with_error "app-fix-case: invalid identifier: $_name"
      ;;
    esac

    if _fix_case_name_is_readonly_constant "$_name"; then
      _target=$(_fix_case_to_upper "$_name")
    else
      _target=$(_fix_case_to_lower "$_name")
    fi

    if [ "$_name" != "$_target" ]; then
      printf '%s\t%s\n' "$_name" "$_target" >>"$_tmp_targets"
    fi
  done
}

_fix_case_all() {
  _tab=$(printf '\t')

  while IFS= read -r _file; do
    sed -n \
      -e "s/^[[:space:]]*\\(function[[:space:]]\\+\\)\\{0,1\\}\\([A-Za-z_][A-Za-z0-9_]*\\)[[:space:]]*().*/function${_tab}\\2/p" \
      -e "s/^[[:space:]]*readonly[[:space:]]\\+\\([A-Za-z_][A-Za-z0-9_]*\\)=.*/readonly${_tab}\\1/p" \
      -e "/^[[:space:]]*readonly[[:space:]]\\+[A-Za-z_][A-Za-z0-9_]*=/d" \
      -e "s/^[[:space:]]*\\(export[[:space:]]\\+\\)\\{0,1\\}\\([A-Za-z_][A-Za-z0-9_]*\\)=.*/variable${_tab}\\2/p" \
      "$_file"
    _fix_case_file_local_variables "$_file" "$_tab"
  done <"$_tmp_files" |
    sort -u |
    while IFS=$_tab read -r _kind _name; do
      case "$_kind" in
      readonly)
        _target=$(_fix_case_to_upper "$_name")
        ;;
      *)
        _target=$(_fix_case_to_lower "$_name")
        ;;
      esac
      [ "$_name" = "$_target" ] || printf '%s\t%s\n' "$_name" "$_target"
    done >"$_tmp_targets"
}

_collect_shell_files() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git ls-files
  else
    find . -type f
  fi | while IFS= read -r _file; do
    [ -f "$_file" ] || continue

    case "$_file" in
    *.sh)
      echo "$_file"
      continue
      ;;
    esac

    _first_line=$(sed -n '1p' "$_file" 2>/dev/null || true)
    case "$_first_line" in
    '#!/bin/sh' | '#!/usr/bin/env sh')
      echo "$_file"
      ;;
    esac
  done
}

_fix_case_has_no_work() {
  [ ! -s "$_tmp_targets" ] && exit_with_success "$0: nothing to change"
}

_fix_case_work() {
  _tab=$(printf '\t')
  _changed=0
  while IFS= read -r _file; do
    [ -f "$_file" ] || continue

    _file_changed=0
    while IFS=$_tab read -r _old _new; do
      [ -n "$_old" ] || continue
      [ -n "$_new" ] || continue

      if grep -Eq "(^|[^[:alnum:]_])$_old([^[:alnum:]_]|$)" "$_file" 2>/dev/null; then
        sed -i -E "s/(^|[^[:alnum:]_])$_old([^[:alnum:]_]|$)/\\1$_new\\2/g" "$_file"
        _file_changed=1
      fi
    done <"$_tmp_targets"

    if [ "$_file_changed" -eq 1 ]; then
      _changed=$((_changed + 1))
    fi
  done <"$_tmp_files"

  log_info "app-fix-case: updated $_changed file(s)"
}
