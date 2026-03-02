cfg feature:.

_maven_run_build() {
  mvn clean install $conf_dev_maven_options "$@" 2>&1 | sed -e '/^WARNING: /d'
}

[ -e pom.xml ] && {
  _maven_run_build "$@"
  return
}

maven_opwd=$PWD
for _MAVEN_PROJECT_DIR in $(extension_find_dirs_containing); do
  cd $_MAVEN_PROJECT_DIR
  _maven_run_build "$@"

  cd $maven_opwd
done
