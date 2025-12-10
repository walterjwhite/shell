lib feature/gpg.feature/gpg.sh

for _SEARCH_ARG in "$@"; do
	case $_SEARCH_ARG in
	*/*)
		_ERROR "Search arguments cannot contain '/': $_SEARCH_ARG"
		;;
	esac

	if [ -z "$_AWK_PATTERN" ]; then
		_AWK_PATTERN="/$_SEARCH_ARG/"
	else
		_AWK_PATTERN="$_AWK_PATTERN && /$_SEARCH_ARG/"
	fi
done

if [ -z "$_AWK_PATTERN" ]; then
	_AWK_PATTERN="//"
fi

[ ! -e $_SECRETS_GPG_PATH ] && _ERROR 'No secrets exist'

_GREP_KEYWORDS=$(printf '%s' "$*" | tr ' ' '|')

find $_SECRETS_GPG_PATH -type f ! -path '*/.git/*' -name '*.gpg' |
	awk "$_AWK_PATTERN" | sort -u | $_CONF_GNU_GREP -P --color "($_GREP_KEYWORDS)"
