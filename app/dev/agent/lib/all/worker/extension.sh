lib extension.sh

agent_run_job_validation_extension() {
  case $agent_extension_type in
  Dockerfile)
    format && build
    ;;
  go)
    format && build
    ;;
  maven)
    format && build
    ;;
  npm)
    format && build
    ;;
  *)
    log_warn "unknown extension type: $agent_extension_type"
    ;;
  esac
}
