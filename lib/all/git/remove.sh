_git_remove_secrets() {
  log_detail "removing secrets"
  find . ! -path '*/.git/*' \( -path '*/*.secret*' -or -path '*/*.archived/*' \) -exec rm -rf {} +
}

_git_remove_artifacts() {
  log_detail "removing artifacts"
  find . -type d \( -name 'target' -or -name 'node_modules' -or -name 'dist' \) ! -path '*/src/*' -exec rm -rf {} +
}

_git_remove_app_framework() {
  log_detail "removing app framework"
  find . -type d \( -name '.log' -or -name '.build' -or -name '.run' \) -exec rm -rf {} +
}

_git_remove_comments() {
  log_detail "removing comments"

  find . -type f ! -path '*/.git/*' ! -name '*.md' -exec $GNU_SED -i '/^[[:blank:]]*#[^!]/d' {} +

  find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $GNU_SED -i '/^[[:space:]]*\/\//d' {} +

  find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $GNU_SED -i '/\/\*\*.*\*\//d' {} +
  find . -type f ! -path '*/.git/*' \( -name '*.java' -or -name '*.go' -or -name '*.rs' -or -name '*.js' \) -exec $GNU_SED -i '/\/\*\*/,/\*\//d' {} +

  find . -type f ! -path '*/.git/*' -name '*.xml' -exec $GNU_SED -i '/<!--.*-->/d' {} +
  find . -type f ! -path '*/.git/*' -name '*.xml' -exec $GNU_SED -i '/<!--/,/-->/d' {} +

  [ -z "$_OPTN_GITHUB_QSY7_COMMENT_REMOVER_DISABLED" ] && {
    qsy7-comment-remover || {
      log_warn "unable to remove Java comments"
      printf '_OPTN_GITHUB_QSY7_COMMENT_REMOVER_DISABLED=1\n' >>$APP_CONFIG_PATH
    }
  }
}

_git_remove_time() {
  find . -type f ! -path '*/.git/*' -exec $GNU_SED -i -E 's/[0-9]{2}:[0-9]{2}:[0-9]{2}/00:00:00/' {} +
}

_git_remove_patterns() {
  pattern_matcher_exclude_pattern_file=$APP_DATA_PATH/.exclude
  touch $pattern_matcher_exclude_pattern_file

  pattern_matcher_pattern_file=${_APP_CONFIG_PATH}.patterns
  if [ ! -e $pattern_matcher_pattern_file ]; then
    log_warn "unable to check contents"
    return
  fi

  log_info "checking contents"

  $GNU_GREP --exclude-dir=.git -f $pattern_matcher_pattern_file . -r | $GNU_GREP -v -f $pattern_matcher_exclude_pattern_file | $GNU_GREP -f $pattern_matcher_pattern_file --color || {
    log_debug "project contents do NOT contain any matches"
    return
  }

  _stdin_continue_if "Accept patterns?" "Y/n" || exit_with_error "user aborted"


}
