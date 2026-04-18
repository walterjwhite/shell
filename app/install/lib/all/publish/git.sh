_push_changes() {

  local app_platform
  for app_platform in $(ls $target_application_name); do
    find $target_application_name/$app_platform -type f -print -quit | grep -cqm1 '.' || {
      log_warn "no files exist for $app_platform"
      continue
    }

    [ -n "$(git status --porcelain "$target_application_name/$app_platform")" ] || {
      log_detail "no changes for $app_platform"
      continue
    }

    git add $target_application_name/$app_platform
    git commit $target_application_name/$app_platform -m "$app_platform:$target_application_name@$target_application_version"
  done

  [ $INSTALL_REGISTRY_OFFLINE ] && {
    log_warn "registry is offline, skipping push changes"
    return 1
  }

  git push || log_warn "unable to push changes"
}

_tag_published_build() {
  cd $publish_wd
  git tag publish/$(date %Y/%m/%d/%s)

  [ $INSTALL_REGISTRY_OFFLINE ] && {
    log_warn "registry is offline, not attempting to push build tag"
    return 1
  }

  git push || log_warn "unable to push build tag"

  unset publish_wd
}
