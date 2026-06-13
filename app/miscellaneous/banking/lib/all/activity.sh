banking_activity() {
  account_id=$1

  require_integer "account id" "$account_id"
  $GNU_GREP -P "^[\d]+,$account_id," $BANKING_TRANSACTIONS_FILE
}
