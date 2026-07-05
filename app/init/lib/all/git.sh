_is_registry_online() {
  git -c http.lowSpeedLimit=1 \
    -c http.lowSpeedTime=$conf_install_app_registry_timeout \
    -c core.sshCommand="ssh -o ConnectTimeout=$conf_install_app_registry_timeout -o ConnectionAttempts=1" \
    ls-remote "$1" HEAD >/dev/null || {
    local status=$?


    return $status
  }
}

_trim_registry_value() {
  printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

_set_registry_from_config() {
  local registries="$conf_init_app_registries"
  local registry_entry

  registry_name=
  registry_url=
  registry_path=
  local selected_registry=$(_trim_registry_value "$1")

  while [ -n "$registries" ]; do
    case $registries in
    *,*)
      registry_entry=${registries%%,*}
      registries=${registries#*,}
      ;;
    *)
      registry_entry=$registries
      registries=
      ;;
    esac

    registry_entry=$(_trim_registry_value "$registry_entry")
    [ -z "$registry_entry" ] && continue

    case $registry_entry in
    *'|'*)
      registry_name=$(_trim_registry_value "${registry_entry%%|*}")
      registry_url=$(_trim_registry_value "${registry_entry#*|}")
      ;;
    *)
      exit_with_error "invalid registry entry '$registry_entry' — expected <registry_name>|<registry_url>"
      return 1
      ;;
    esac

    [ -z "$registry_name" ] && {
      exit_with_error "invalid registry entry '$registry_entry' — missing registry name"
      return 1
    }
    [ -z "$registry_url" ] && {
      exit_with_error "invalid registry entry '$registry_entry' — missing registry url"
      return 1
    }

    if [ "$registry_name" = "$selected_registry" ]; then
      registry_path=$REGISTRY_PATH/$registry_name
      return 0
    fi
  done

  exit_with_error "registry '$selected_registry' not found in conf_init_app_registries"
}

_set_registry() {
  _set_registry_from_config "${use_registry:-default}"
}

_git_init_registries() {
  log_info "init registries"
  local registries="$conf_init_app_registries"
  local registry_entry

  local registry_name registry_url

  while [ -n "$registries" ]; do
    case $registries in
    *,*)
      registry_entry=${registries%%,*}
      registries=${registries#*,}
      ;;
    *)
      registry_entry=$registries
      registries=
      ;;
    esac

    registry_entry=$(_trim_registry_value "$registry_entry")
    [ -z "$registry_entry" ] && continue

    case $registry_entry in
    *'|'*)
      registry_name=$(_trim_registry_value "${registry_entry%%|*}")
      registry_url=$(_trim_registry_value "${registry_entry#*|}")
      ;;
    *)
      exit_with_error "invalid registry entry '$registry_entry' — expected <registry_name>|<registry_url>"
      return 1
      ;;
    esac

    [ -z "$registry_name" ] && {
      exit_with_error "invalid registry entry '$registry_entry' — missing registry name"
      return 1
    }
    [ -z "$registry_url" ] && {
      exit_with_error "invalid registry entry '$registry_entry' — missing registry url"
      return 1
    }

    _is_registry_online "$registry_url" || {
      log_warn "registry is offline $registry_name"
      continue
    }

    local registry_path=$REGISTRY_PATH/$registry_name
    _git_do_clone "$registry_url" "$registry_path"
  done
}
