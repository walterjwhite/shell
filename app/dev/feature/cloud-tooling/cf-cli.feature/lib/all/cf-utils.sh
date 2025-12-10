_cf_endpoint() {
	CF_ENDPOINT=$(env | grep CF_${CF_ENVIRONMENT}_ENDPOINT= | sed -e 's/^.*=//')
	_require "$CF_ENDPOINT" "CF_ENDPOINT - $CF_ENVIRONMENT (CF_${CF_ENVIRONMENT}_ENDPOINT)"
}

_cf_space_index() {
	CF_SPACE_INDEX=$(env | grep CF_${CF_SPACE}_SPACE_INDEX= | sed -e 's/^.*=//')
	_require "$CF_SPACE_INDEX" "CF_SPACE - $CF_SPACE_INDEX (CF_${CF_SPACE}_SPACE_INDEX)"
}
