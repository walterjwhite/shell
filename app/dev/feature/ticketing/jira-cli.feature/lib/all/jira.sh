_jira() {
	local uri=$1
	shift

	curl -u "$_CONF_DEV_JIRA_CLI_LOGIN:$_CONF_DEV_JIRA_CLI_API_TOKEN" \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		"$@" \
		"$_CONF_DEV_JIRA_CLI_URL/rest/api/3/$uri" | jq
}

_JIRA_ASSIGN() {
	_JIRA_GET_TICKET

	_require "$1" "jira account id: _JIRA_ASSIGN"

	local assignee=$1
	shift

	local account_id
	case $assignee in
	unassign)
		account_id=null
		;;
	default)
		account_id=-1
		;;
	self)
		account_id=$_CONF_DEV_JIRA_CLI_ACCOUNT_ID
		;;
	*)
		account_id=$assignee
		;;
	esac

	_jira "issue/$JIRA_TICKET_ID/assignee" \
		-X PUT \
		-d "{\"accountId\": \"$account_id\"}"
}

_JIRA_CREATE() {
	local summary="$1"
	local description="$2"
	local issue_type="$3"

	if [ -n "$4" ]; then
		custom_fields=",$4"
	fi

	_jira "issue" \
		-X POST \
		-d "{\"fields\": {\"project\": {\"id\": \"$_CONF_DEV_JIRA_CLI_PROJECT\"}, \"summary\": \"$summary\", \"description\": \"$description\", \"issuetype\": {\"id\":\"$issue_type\"}$custom_fields}}"
}

_JIRA_COMMENT() {
	_JIRA_GET_TICKET

	_require "$1" "Comment Body"
	_jira "issue/$JIRA_TICKET_ID/comment" \
		-X POST \
		-d "{\"body\": {\"version\":1, \"type\":\"doc\", \"content\":[{\"type\":\"paragraph\", \"content\": [{\"type\": \"text\", \"text\": \"$1\"}]}]}}"
}

_JIRA_TRANSITION() {
	_JIRA_GET_TICKET

	local transition_id=$(printf '%s\n' $_CONF_DEV_JIRA_TRANSITIONS | tr '|' '\n' | grep ":${1}$" | cut -f1 -d':')
	_require "$transition_id" "transition_id _JIRA_TRANSITION [$_CONF_DEV_JIRA_TRANSITIONS] $1"

	_jira "issue/$JIRA_TICKET_ID/transitions" \
		-X POST \
		-d "{\"transition\": {\"id\": \"$transition_id\"}}"
}

_JIRA_GET_TICKET() {
	JIRA_TICKET_ID="$_CONSOLE_CONTEXT_ID"
	_require "$JIRA_TICKET_ID" "JIRA_TICKET_ID (_CONSOLE_CONTEXT_ID)"
}
