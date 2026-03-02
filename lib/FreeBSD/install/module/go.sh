go_bootstrap_post() {
  [ -e /usr/local/bin/go125 ] && [ ! -e /usr/local/bin/go ] && {
    ln -s /usr/local/bin/go125 /usr/local/bin/go
    ln -s /usr/local/bin/gofmt125 /usr/local/bin/gofmt
  }
}
