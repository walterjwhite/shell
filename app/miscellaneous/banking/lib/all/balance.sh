banking_balance() {
  account_id=$1
  require_integer "account id" "$account_id"
  require_account "$account_id"
  current_balance "$account_id"
}

current_balance() {
  awk -F',' -v account_id="$account_id" 'NR>1 && $1==account_id { val=$4 } END { if (val == "") print "0"; else print val }' "$BANKING_BALANCES_FILE"
}

_update_account_balances() {
  account_id="$1"
  transaction_id="$2"
  transaction_date="$3"
  amount="$4"
  account_balance=$(current_balance "$account_id")
  account_balance=$(printf '%s + %s\n' "$account_balance" "$amount" | bc)

  printf '%s,%s,%s,%s\n' \
    "$account_id" \
    "$transaction_id" \
    "$transaction_date" \
    "$account_balance" >>"$BANKING_BALANCES_FILE"
}
