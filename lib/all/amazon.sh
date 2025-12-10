_amazon_href() {
	printf '%s' "$1" | sed -e "s/\/ref=.*$//"
}
