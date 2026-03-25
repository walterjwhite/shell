lib git/github.sh

get_installed_cagent_version() {
  cagent version 2>/dev/null | head -1 | sed -e 's/^.*v/v/'
}
