_npm_bootstrap_pre() {
  case $APP_PLATFORM_SUB_PLATFORM in
  Gentoo)
    local _use_flag_file=/tmp/install-gentoo-npm.use
    printf '%s npm\n' $NPM_PACKAGE >$_use_flag_file
    package_use_install $_use_flag_file

    rm -f $_use_flag_file
    unset _use_flag_file
    ;;
  esac
}
