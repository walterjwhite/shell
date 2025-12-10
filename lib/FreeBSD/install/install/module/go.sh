_GO_BOOTSTRAP_POST() {
	[ -e /usr/local/bin/go123 ] && [ ! -e /usr/local/bin/go ] && {
		ln -s /usr/local/bin/go123 /usr/local/bin/go
		ln -s /usr/local/bin/gofmt123 /usr/local/bin/gofmt
	}
}
