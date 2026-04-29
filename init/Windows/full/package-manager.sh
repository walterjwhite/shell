if [ -n "$WINGET" ]; then
  windows_package_manager=winget
elif [ -n "$CHOCOLATEY" ]; then
  windows_package_manager=chocolatey
elif [ -n "$SCOOP" ]; then
  windows_package_manager=scoop
fi
