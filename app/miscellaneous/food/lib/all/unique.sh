_unique_ingredients() {
  if [ $(find . -maxdepth 1 -type f -name '*ingredients' -print -quit | wc -l) -eq 0 ]; then
    find . -type f -name '*ingredients' -exec awk -F',' {'print$3'} {} + | tr '|' '\n' | sort -u | grep -v '^$'
    return
  fi

  for _INGREDIENT_FILE in $(find . -maxdepth 1 -type f -name '*ingredients'); do
    _unique_ingredients_file "$_INGREDIENT_FILE"
  done
}

_unique_ingredients_file() {
  local name="$(basename $_INGREDIENT_FILE | sed -e 's/\.ingredients$//' | tr '-' ' ')"
  if [ "$name" = "ingredients" ]; then
    name=Main
  fi

  log_detail "$name:"

  awk -F',' {'print$3'} $1 | tr '|' '\n' | sort -u | grep -v '^$'

  printf '\n'
}
