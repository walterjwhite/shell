lib net/download.sh

_git_github_latest_release() {
	curl -sL https://api.github.com/repos/$1/$2/releases/latest | grep tag_name | awk {'print$2'} | tr -d '"' | tr -d ','
}

_git_github_fetch_latest_artifact() {
	local github_organization_name=$1
	local github_repository_name=$2
	local artifact_name=$3
	local artifact_suffix=$4
	shift 4

	local latest_version=$(_git_github_latest_release $github_organization_name $github_repository_name)
	[ -z "$artifact_url_function" ] && artifact_url_function=_git_github_artifact_url

	$artifact_url_function $github_organization_name $github_repository_name $latest_version $artifact_name $artifact_suffix
	_download $_GITHUB_ARTIFACT_URL "$@"

	unset _GITHUB_ARTIFACT_URL
}

_git_github_artifact_url() {
	_GITHUB_ARTIFACT_URL=https://github.com/$1/$2/releases/download/${3}/${4}${3}${5}
}

_git_github_artifact_url_static() {
	_GITHUB_ARTIFACT_URL=https://github.com/$1/$2/releases/download/${3}/${4}
}
