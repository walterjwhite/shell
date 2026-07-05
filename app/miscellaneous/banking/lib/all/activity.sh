banking_activity() {
  account_id=$1

  require_integer "account id" "$account_id"
  awk -F',' -v id="$account_id" 'NR>1 && $2==id { print }' "$BANKING_TRANSACTIONS_FILE"
}
