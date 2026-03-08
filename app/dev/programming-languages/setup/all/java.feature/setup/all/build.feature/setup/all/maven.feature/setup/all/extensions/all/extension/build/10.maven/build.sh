cfg feature:.

_maven_run_build() {
  mvn clean install $conf_dev_maven_options "$@" 2>&1
}

[ -e pom.xml ] && {
  _maven_run_build "$@"
  return
}

maven_err_count=0
maven_opwd=$PWD
for _MAVEN_PROJECT_DIR in $(extension_find_dirs_containing); do
  cd $_MAVEN_PROJECT_DIR
  _maven_run_build "$@" || {
    maven_err_count=$(($maven_err_count + 1))
  }

  cd $maven_opwd
done

return $maven_err_count
