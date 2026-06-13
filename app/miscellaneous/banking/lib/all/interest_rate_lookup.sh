_interest_rate_for_month() {
  target_month=$1
  require_year_month "$target_month"

  rate_lookup=$(
    awk -F',' -v target_month="$target_month" '
      NR == 1 { next }

      $1 == target_month {
        print $2
        found = 1
        exit
      }

      $1 < target_month && (best_month == "" || $1 > best_month) {
        best_month = $1
        best_rate = $2
      }

      END {
        if (!found && best_month != "") {
          print "INSERT," best_month "," best_rate
        }
      }
    ' "$BANKING_INTEREST_RATE_FILE"
  )

  [ -n "$rate_lookup" ] || exit_with_error "no interest rate found for $target_month in $BANKING_INTEREST_RATE_FILE"

  case "$rate_lookup" in
  INSERT,*)
    inherited_rate=$(printf '%s\n' "$rate_lookup" | cut -d',' -f3)
    require_number "interest rate" "$inherited_rate"
    printf '%s,%s\n' "$target_month" "$inherited_rate" >>"$BANKING_INTEREST_RATE_FILE"
    BANKING_INTEREST_RATE=$inherited_rate
    BANKING_INTEREST_RATE_FILE_CHANGED=1
    ;;
  *)
    require_number "interest rate" "$rate_lookup"
    BANKING_INTEREST_RATE=$rate_lookup
    BANKING_INTEREST_RATE_FILE_CHANGED=${BANKING_INTEREST_RATE_FILE_CHANGED:-0}
    ;;
  esac
}
