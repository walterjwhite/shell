_android_run_build() {
  gradle wrapper --gradle-version \
    $(grep distributionUrl gradle/wrapper/gradle-wrapper.properties | sed -n 's/.*gradle-\([0-9.]*\)-bin.zip/\1/p')

  case $gradle_build_type in
  debug)
    gradle_build_arg=Debug
    ;;
  release)
    gradle_build_arg=Release
    ;;
  *)
    exit_with_error "invalid build type: $gradle_build_type"
    ;;
  esac

  ./gradlew clean assemble$gradle_build_arg
}

_android_is_android_project() {
  [ ! -e build.gradle ] && [ ! -e build.gradle.kts ] && return 1

  grep -cqm1 "com.android.application\|com.android.library" build.gradle build.gradle.kts 2>/dev/null
}

_android_is_android_project && {
  _android_run_build "$@"
  return
}

android_err_count=0
android_opwd=$PWD
for _ANDROID_PROJECT_DIR in $(extension_find_dirs_containing); do
  cd $_ANDROID_PROJECT_DIR
  _android_is_android_project || continue

  _android_run_build "$@" || {
    android_err_count=$(($android_err_count + 1))
  }

  cd $android_opwd
done

return $android_err_count
