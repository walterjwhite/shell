_github_iterate() {
  cd $APP_DATA_PATH
  cd $git_project_name
  file_require .git

  gcommit -am "$conf_github_commit_message"

  if [ -n "$conf_github_comit_time" ]; then
    git_commit_date_time=$(git log -1 --pretty=format:'%ci' | sed -E "s/[0-9]{2}:[0-9]{2}:[0-9]{2}/$conf_github_comit_time/")
    gad "$git_commit_date_time"
  fi

  if [ -n "$_OPTN_GITHUB_FIXUP_ROOT" ]; then
    commits_to_squash=$(gl | grep ^commit | wc -l)
    commits_to_squash=$(($commits_to_squash - 1))

    gf $commits_to_squash -m="$conf_github_commit_message"

    github_push_options="--force"
  fi


  gpush origin $conf_github_target_branch $github_push_options

  _github_push_tags

  cd ..
  rm -Rf $git_project_name
}

_github_push_tags() {
  cd $setup_github_clone_source_project
  git tag github.com/$(date $conf_github_date_tag_format)
  git push --tags

  cd $_pwd
}

_github_iterate_cleanup() {
  :
}
