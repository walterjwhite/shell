_github_tag() {
	local original_pwd=$PWD

	cd $_SOURCE_PROJECT
	git tag github.com/$(date $_CONF_GITHUB_DATE_TAG_FORMAT)
	gpush --tags

	cd $original_pwd
}

_github_sync() {
	[ ! -e $_GITHUB_PROJECT_PATH ] && _ERROR "$_GITHUB_PROJECT_PATH does not exist!"
	cd $_GITHUB_PROJECT_PATH

	[ -z "$_NEW" ] && _ git pull

	local project_name=$(basename $PWD)

	_github_remove_contents
	_github_copy_source

	_github_remove_secrets
	_github_remove_artifacts
	_github_remove_comments
	_github_remove_time

	if [ -n "$_OPTN_GITHUB_IGNORE" ]; then
		_INFO "removing other filtered content: $_OPTN_GITHUB_IGNORE"
		_ rm -rf $_OPTN_GITHUB_IGNORE
	fi
}

_github_remove_contents() {
	_DETAIL "Clearing repository contents $PWD"
	find . -mindepth 1 -maxdepth 1 ! -name .git ! -name '.' -exec rm -rf {} +
}

_github_copy_source() {
	_DETAIL "Copying modified project contents"
	[ -e $_PROJECT_PATH/.app ] && cp -Rp $_PROJECT_PATH/.app .
	[ -e $_PROJECT_PATH/.github ] && cp -Rp $_PROJECT_PATH/.github .
	[ -e $_PROJECT_PATH/.gitignore ] && cp -Rp $_PROJECT_PATH/.gitignore .
	find $_PROJECT_PATH -mindepth 1 -maxdepth 1 ! -name '.*' ! -name '*.secret*' ! -name github ! -name system-configuration -exec cp -Rp {} $_GITHUB_PROJECT_PATH/ \;
}

_github_remove_secrets() {
	_DETAIL "removing secrets"
	find . ! -path '*/.git/*' \( -path '*/*.secret*' -or -path '*/*.archived/*' \) -exec rm -rf {} +
}

_github_remove_artifacts() {
	_DETAIL "removing artifacts"
	find . -type d -name 'target' ! -path '*/src/*' -exec rm -rf {} +
}

_github_remove_comments() {
	_DETAIL "removing comments"

	find . -type f ! -path '*/.git/*' ! -name '*.md' -exec $_CONF_GNU_SED -i '/^[[:blank:]]*#[^!]/d' {} +

	find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $_CONF_GNU_SED -i '/^[[:space:]]*\/\//d' {} +

	find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $_CONF_GNU_SED -i '/\/\*\*.*\*\//d' {} +
	find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $_CONF_GNU_SED -i '/\/\*\*/,/\*\//d' {} +

	find . -type f ! -path '*/.git/*' -name '*.xml' -exec $_CONF_GNU_SED -i '/<!--.*-->/d' {} +
	find . -type f ! -path '*/.git/*' -name '*.xml' -exec $_CONF_GNU_SED -i '/<!--/,/-->/d' {} +

	[ -z "$_OPTN_GITHUB_QSY7_COMMENT_REMOVER_DISABLED" ] && {
		qsy7-comment-remover || {
			_WARN "Unable to remove Java comments"
			printf '_OPTN_GITHUB_QSY7_COMMENT_REMOVER_DISABLED=1\n' >>$_CONF_APPLICATION_CONFIG_PATH
		}
	}
}

_github_remove_time() {
	find . -type f ! -path '*/.git/*' -exec $_CONF_GNU_SED -i -E 's/[0-9]{2}:[0-9]{2}:[0-9]{2}/00:00:00/' {} +
}
