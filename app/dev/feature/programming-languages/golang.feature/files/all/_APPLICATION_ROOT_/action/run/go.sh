lib io/file.sh
lib ./logging.sh
lib ./run.sh
lib ./secrets.sh

_GO_NEW_INSTANCE() {
	_ERROR "not implemented"
}

_RUN_GO_INIT() {
	_DEV_NOTAIL=1
}

_RUN_GO() {
	_GO_CMD_NAME=$(basename $PWD)
	~/go/bin/$_GO_CMD_NAME "$@"
}
