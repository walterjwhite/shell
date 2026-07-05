if [ -z "$windows_package_manager" ]; then
  if command -v winget >/dev/null 2>&1; then
    windows_package_manager=winget
  elif command -v choco >/dev/null 2>&1; then
    windows_package_manager=chocolatey
  elif command -v scoop >/dev/null 2>&1; then
    windows_package_manager=scoop
  else
    windows_package_manager=disabled
  fi
fi

case "$windows_package_manager" in
"winget" | "chocolatey" | "scoop")
  ;;
*)
  windows_package_manager=disabled
  ;;
esac
