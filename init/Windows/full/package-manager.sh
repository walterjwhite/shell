if [ -n "$WINGET" ]; then
    log_warn "has winget"
    windows_package_manager=winget
elif [ -n "$CHOCOLATEY" ]; then
    log_warn "has chocolatey"
    windows_package_manager=chocolatey
elif [ -n "$SCOOP" ]; then
    log_warn "has scoop"
    windows_package_manager=scoop
else
    exit_with_error "no package manager detected"
fi
