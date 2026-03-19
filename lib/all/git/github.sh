lib net/download.sh

_github_latest_release() {
  curl -sL https://api.github.com/repos/$1/$2/releases/latest | jq -r ".tag_name"
}

_github_fetch_latest_artifact() {
  local _github_organization_name=$1
  local _github_repository_name=$2
  local _artifact_name=$3
  local _artifact_suffix=$4
  shift 4

  local _latest_version=$(_github_latest_release $_github_organization_name $_github_repository_name)
  [ -z "$git_artifact_url_function" ] && git_artifact_url_function=_github_artifact_url

  $git_artifact_url_function $_github_organization_name $_github_repository_name $_latest_version $_artifact_name $_artifact_suffix
  _download_fetch $git_github_artifact_url "$@"

  unset git_github_artifact_url
}

_github_artifact_url() {
  git_github_artifact_url=https://github.com/$1/$2/releases/download/${3}/${4}${3}${5}
}

_github_artifact_url_static() {
  git_github_artifact_url=https://github.com/$1/$2/releases/download/${3}/${4}
}
