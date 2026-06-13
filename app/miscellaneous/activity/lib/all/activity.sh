lib git/data.app.sh
lib git/project.directory.sh
lib time.sh

cfg git

_activity_init() {


  _data_app_init $1
  _activity_directory=$git_project_path/.activity
}

_activity_decade_path() {
  date_path=$(date +%Y/%m.%B/%d/%H.%M.%S)
  decade=$(_time_decade)

  printf '%s/%s\n' "$decade" "$date_path"
}
