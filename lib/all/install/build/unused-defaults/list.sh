_list_variables() {
	$_CONF_GNU_GREP -Pho '\$(\{?)[\w]{3,}(:?)=' $1 | sed -e 's/^\${//' -e 's/^\$//' -e 's/:=//' -e 's/=//' | sort -u
}

_used_variables() {
	$_CONF_GNU_GREP -Po '\$({?)[\w]{3,}' $1 | sed -e 's/^\${//' -e 's/^\$//' | sort -u

	grep export $1 | $_CONF_GNU_GREP -Pho '\$(\{?)[\w]{3,}' | sed -e 's/^\${//' -e 's/^\$//'
}
