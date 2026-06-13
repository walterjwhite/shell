banking_transact() {
  account_id=$1
  amount=$2
  description=$3
  transaction_date=$4

  [ -n "$transaction_date" ] || transaction_date=$(date +%Y-%m-%d)

  require_integer "account id" "$account_id"
  require_number "amount" "$amount"
  require_date "$transaction_date"
  require_account "$account_id"

  awk -v amount="$amount" 'BEGIN { exit((amount + 0) == 0 ? 0 : 1) }' && exit_with_error "amount must be non-zero"

  _append_transaction "$account_id" "$amount" "$description" "$transaction_date"
  _data_app_save "$account_id - $description" "$BANKING_BALANCES_FILE" "$BANKING_TRANSACTIONS_FILE"
}

_append_transaction() {
  transaction_id=$(_next_transaction_id)
  amount=$(format_money "$amount")

  printf '%s,%s,%s,%s,%s\n' \
    "$transaction_id" \
    "$account_id" \
    "$transaction_date" \
    "$amount" \
    "$(csv_quote "$description")" >>"$BANKING_TRANSACTIONS_FILE"

  _update_account_balances "$account_id"
}

_next_transaction_id() {
  awk -F',' '
    NR > 1 && ($1 + 0) > max { max = $1 + 0 }
    END { print max + 1 }
  ' "$BANKING_TRANSACTIONS_FILE"
}
