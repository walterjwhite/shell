banking_balance() {
  account_id=$1
  require_integer "account id" "$account_id"
  require_account "$account_id"
  current_balance "$account_id"
}

current_balance() {
  $GNU_GREP -P "^$account_id," "$BANKING_BALANCES_FILE" | tail -1 | cut -f4 -d,
}

_update_account_balances() {
  account_balance=$(current_balance $1)
  account_balance=$(printf '%s + %s\n' "$account_balance" "$amount" | bc)

  printf '%s,%s,%s,%s\n' \
    "$account_id" \
    "$transaction_id" \
    "$transaction_date" \
    "$account_balance" >>"$BANKING_BALANCES_FILE"
}
