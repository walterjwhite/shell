_colored_tail() {
	_ESC=$(printf '\033')

	tail -f $_RUN_LOG_FILE |
		sed -u -e "s, TRACE ,${_ESC}[34m&${_ESC}[0m," \
			-e "s, DEBUG ,${_ESC}[35m&${_ESC}[0m," \
			-e "s, INFO ,${_ESC}[36m&${_ESC}[0m," \
			-e "s, WARN ,${_ESC}[33m&${_ESC}[0m," \
			-e "s, ERROR ,${_ESC}[31m&${_ESC}[0m,"
}
