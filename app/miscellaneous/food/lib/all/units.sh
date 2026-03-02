_units_ingredients() {
  find . -type f -name '*ingredients' -exec awk -F',' {'print$2'} {} + | tr '|' '\n' | sort -u | grep -v '^$'
}
