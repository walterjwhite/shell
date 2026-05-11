lib extension.sh

_agent_validate_documentation() {
  [ -z "$agent_documentation_path" ] && return 0

  find . -type f -path "*/$agent_documentation_path/*.md" -print -quit | grep -cqm1 '.'
}
