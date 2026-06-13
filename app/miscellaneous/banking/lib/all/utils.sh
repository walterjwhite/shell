_banking_init() {
  _data_app_init banking

  readonly BANKING_ACCOUNTS_FILE=$git_project_path/accounts.csv
  readonly BANKING_BALANCES_FILE=$git_project_path/account_balances.csv
  readonly BANKING_TRANSACTIONS_FILE=$git_project_path/transactions.csv
  readonly BANKING_INTEREST_RATE_FILE=$git_project_path/interest_rate.csv

  local initialized=0
  [ -f "$BANKING_ACCOUNTS_FILE" ] || {
    printf 'id,name\n' >"$BANKING_ACCOUNTS_FILE"
    initialized=1
  }
  [ -f "$BANKING_BALANCES_FILE" ] || {
    printf 'account_id,transaction_id,date,balance\n' >"$BANKING_BALANCES_FILE"
    initialized=1
  }

  [ -f "$BANKING_TRANSACTIONS_FILE" ] || {
    printf 'id,account_id,date,amount,description\n' >"$BANKING_TRANSACTIONS_FILE"
    initialized=1
  }
  [ -f "$BANKING_INTEREST_RATE_FILE" ] || {
    printf 'year_month,interest_rate\n' >"$BANKING_INTEREST_RATE_FILE"
    initialized=1
  }

  [ $initialized -eq 1 ] && {
    git add .
    git commit -am 'init data structures'
    git push
  }
}

csv_quote() {
  printf '%s' "$1" | sed 's/"/""/g; 1s/^/"/; $s/$/"/'
}

format_money() {
  awk -v amount="$1" 'BEGIN { printf "%.2f\n", amount + 0 }'
}
