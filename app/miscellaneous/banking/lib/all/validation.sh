require_account() {
  awk -F',' -v account_id="$1" '
    NR > 1 && $1 == account_id { found = 1; exit }
    END { exit(found ? 0 : 1) }
  ' "$BANKING_ACCOUNTS_FILE" || exit_with_error "unknown account id: $1"
}

require_integer() {
  printf '%s\n' "$2" | grep -Eq '^[0-9]+$' || exit_with_error "$1 must be an integer: $2"
}

require_number() {
  printf '%s\n' "$2" | grep -Eq '^-?[0-9]+([.][0-9]+)?$' || exit_with_error "$1 must be numeric: $2"
}


require_date() {
  printf '%s\n' "$1" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' || exit_with_error "date must be YYYY-MM-DD: $1"
}

require_year_month() {
  printf '%s\n' "$1" | grep -Eq '^[0-9]{4}-[0-9]{2}$' || exit_with_error "year month must be YYYY-MM: $1"
}
