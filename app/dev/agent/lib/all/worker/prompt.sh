lib io/file.sh

_worker_get_prompt() {
  file_require ./prompt.md
  worker_agent_prompt=$(_file_readlink ./prompt.md)
}
