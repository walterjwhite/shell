lib extension.sh

agent_run_job_validation_extension() {
  _agent_validate_documentation

  case $agent_extension_type in
  Dockerfile)
    format && build
    ;;
  go)
    format && build
    ;;
  maven)
    format && build && _jacoco_coverage
    ;;
  npm)
    format && build
    ;;
  sh)
    format
    ;;
  *)
    log_warn "unknown extension type: $agent_extension_type"
    ;;
  esac

  exec_call _agent_validate_prompt_output
}

_agent_validate_documentation() {
  [ -z "$agent_documentation_path" ] && return 0

  find . -type f -path "*/$agent_documentation_path/*.md" -print -quit | grep -cqm1 '.'
}
