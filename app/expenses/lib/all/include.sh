lib time.sh

_expenses_set_filename() {
	if [ $# -gt 0 ]; then
		if [ -d $1 ]; then
			_expenses_filename $1
		else
			_EXPENSES_FILE=$1
		fi

		shift
		return
	fi

	_expenses_filename
	return 1
}

_expenses_filename() {
	local decade=$(_time_decade)
	local name=$(date +%Y)

	local directory=$_CONF_APPLICATION_DATA_PATH
	if [ $# -gt 0 ]; then
		directory=$1
		shift
	fi

	_EXPENSES_FILE=$directory/.expenses/$decade/$name.csv
	mkdir -p $(dirname $_EXPENSES_FILE)
}
