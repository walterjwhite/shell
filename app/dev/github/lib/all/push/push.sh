_github_iterate() {
  cd $APP_DATA_PATH/$git_project_name
  file_require .git

  if [ -n "$optn_github_fixup_root" ]; then
    git checkout --orphan tmp-clean

    github_push_options="--force"
  fi

  git commit -m "$conf_github_commit_message"

  if [ -n "$conf_github_comit_time" ]; then
    git_commit_date_time=$(git log -1 --pretty=format:'%ci' | sed -E "s/[0-9]{2}:[0-9]{2}:[0-9]{2}/$conf_github_comit_time/")
    gad "$git_commit_date_time"
  fi


  git push $github_push_options origin tmp-clean:$conf_github_target_branch

  _github_push_tags

  cd ..
  rm -Rf $git_project_name
}

_github_push_tags() {
  cd $_pwd
  git tag github.com/$(date $conf_github_date_tag_format)
  git push --tags

  cd $APP_DATA_PATH/$git_project_name
}

_github_iterate_cleanup() {
  :
}
