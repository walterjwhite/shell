banking_interest() {
  target_month=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m)
  month_start=$(date -d "$target_month-01 00:00:00" +%s)
  next_month_start=$(date -d "$target_month-01 +1 month 00:00:00" +%s)
  _interest_rate_for_month "$target_month"
  interest_rate="$BANKING_INTEREST_RATE"
  changed=0
  interest_rate_file_changed=${BANKING_INTEREST_RATE_FILE_CHANGED:-0}

  for account_id in $(sed 1d "$BANKING_ACCOUNTS_FILE" | cut -f1 -d,); do
    [ -z "$account_id" ] && continue

    if account_has_interest_for_month "$account_id" "$target_month"; then
      continue
    fi

    average_balance=$(_average_balance_for_month "$account_id" "$month_start" "$next_month_start")
    interest_amount=$(awk -v average_balance="$average_balance" -v rate="$interest_rate" 'BEGIN { printf "%.2f\n", average_balance * (rate / 12) }')

    awk -v amount="$interest_amount" 'BEGIN { exit((amount + 0) == 0 ? 0 : 1) }' && continue

    amount="$interest_amount"
    description="interest - $target_month"

    _append_transaction
    changed=1
  done

  [ "$changed" -eq 1 ] || {
    [ "$interest_rate_file_changed" -eq 0 ] || _data_app_save "interest rate - $target_month" "$BANKING_INTEREST_RATE_FILE"
    exit_with_error "no interest entries created for $target_month"
  }

  if [ "$interest_rate_file_changed" -eq 1 ]; then
    _data_app_save "interest - $target_month" "$BANKING_BALANCES_FILE" "$BANKING_TRANSACTIONS_FILE" "$BANKING_INTEREST_RATE_FILE"
  else
    _data_app_save "interest - $target_month" "$BANKING_BALANCES_FILE" "$BANKING_TRANSACTIONS_FILE"
  fi
}

account_has_interest_for_month() {
  awk -F',' -v account_id="$1" -v expected="\"interest - $2\"" '
    NR > 1 && $2 == account_id && $5 == expected { found = 1; exit }
    END { exit(found ? 0 : 1) }
  ' "$BANKING_TRANSACTIONS_FILE"
}
