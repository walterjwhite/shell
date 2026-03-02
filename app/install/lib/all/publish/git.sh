_push_changes() {
  git add $target_application_name
  git commit $target_application_name -m "$APP_PLATFORM_PLATFORM:$target_application_name@$target_application_version"

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
