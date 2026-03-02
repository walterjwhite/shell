_list_ingredients() {
  _list_ingredients_file ingredients Main
  for _INGREDIENT_FILE in $(find . -maxdepth 1 -type f -name '*.ingredients'); do
    _list_ingredients_file "$_INGREDIENT_FILE" "$(basename $_INGREDIENT_FILE | sed -e 's/\.ingredients$//' | tr '-' ' ')"
  done
}

_list_ingredients_file() {
  log_detail "ingredients: $2"
  awk -F, '{printf "%-5s %-5s %-30s %-20s\n",$1,$2,$3,$4}' $1

  printf '\n'
}

