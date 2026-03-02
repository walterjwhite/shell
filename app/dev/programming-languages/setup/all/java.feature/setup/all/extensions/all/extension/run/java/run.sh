lib io/file.sh

_java_debug() {
  debug_args="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=$debug_port"
}

_runner_init() {
  [ -n "$java_framework" ] && {
    . __LIBRARY_PATH__/install/extensions/extension/$extension_action/$extension_run_type/framework/${java_framework}.sh


  }

  _run_java_locate_application

  [ -z "$application" ] && exit_with_error "application is not defined, unable to run application"

  [ $debug ] && _java_debug
}

_run_java_locate_application() {
  [ -z "$application" ] && application=$(find target -maxdepth 1 -type f ! -name '*.javadoc' ! -name '*.sources' ! -name '*.jar.original' -name '*.jar')
}

_runner_run() {
  if [ -n "$_AGENT" ]; then
    file_require "$_AGENT" _AGENT
    local agent_args="${agent_args} -javaagent:$_AGENT"
  fi

  java $agent_args $debug_args $java_args -jar $application "$@" &
  run_pid=$!
}

