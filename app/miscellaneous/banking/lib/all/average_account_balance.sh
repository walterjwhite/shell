_average_balance_for_month() {
  account_id=$1
  month_start=$2
  next_month_start=$3
  points_file=$(mktemp)

  opening_balance=$(
    awk -F',' -v account_id="$account_id" -v month_start="$month_start" '
      FNR == NR {
        if (NR > 1) {
          balance_by_transaction[$2] = $4
        }

        next
      }

      NR > 1 && $2 == account_id && ($3 + 0) < month_start {
        if (($3 + 0) > best_date || (($3 + 0) == best_date && ($1 + 0) > best_transaction_id)) {
          best_date = $3 + 0
          best_transaction_id = $1 + 0
          best_balance = balance_by_transaction[$1]
        }
      }

      END {
        if (best_balance == "") {
          best_balance = 0
        }

        printf "%.2f\n", best_balance + 0
      }
    ' "$BANKING_BALANCES_FILE" "$BANKING_TRANSACTIONS_FILE"
  )

  awk -F',' -v account_id="$account_id" -v month_start="$month_start" -v next_month_start="$next_month_start" '
    FNR == NR {
      if (NR > 1) {
        balance_by_transaction[$2] = $4
      }

      next
    }

    NR > 1 && $2 == account_id && ($3 + 0) >= month_start && ($3 + 0) < next_month_start {
      print ($3 + 0) "," ($1 + 0) "," balance_by_transaction[$1]
    }
  ' "$BANKING_BALANCES_FILE" "$BANKING_TRANSACTIONS_FILE" | sort -t',' -k1,1n -k2,2n >"$points_file"

  awk -F',' -v month_start="$month_start" -v next_month_start="$next_month_start" -v opening_balance="$opening_balance" '
    BEGIN {
      previous_date = month_start + 0
      balance = opening_balance + 0
      weighted_total = 0
    }

    NF >= 3 {
      current_date = $1 + 0
      next_balance = $3 + 0

      if (current_date > previous_date) {
        weighted_total += balance * (current_date - previous_date)
      }

      balance = next_balance
      previous_date = current_date
    }

    END {
      if ((next_month_start + 0) > previous_date) {
        weighted_total += balance * ((next_month_start + 0) - previous_date)
      }

      if ((next_month_start + 0) <= (month_start + 0)) {
        print "0.00"
      } else {
        printf "%.2f\n", weighted_total / ((next_month_start + 0) - (month_start + 0))
      }
    }
  ' "$points_file"

  rm -f "$points_file"
}
