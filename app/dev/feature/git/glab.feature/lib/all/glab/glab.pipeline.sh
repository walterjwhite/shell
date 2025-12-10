_glab_pipeline_status() {
	_GLAB_PIPELINE_STATUS=$(glab pipeline status | grep $_GLAB_PIPELINE_STAGE | awk {'print$1'} | tr -d '(' | tr -d ')')

	_require "$_GLAB_PIPELINE_STATUS" _GLAB_PIPELINE_STATUS
}

_glab_pipeline_status_is_terminal() {
	case $_GLAB_PIPELINE_STATUS in
	running | pending | created | waiting_for_resource | preparing | pending | manual | scheduled)
		return 1
		;;
	*)
		return 0
		;;
	esac
}

_glab_pipeline_status_is_success() {
	case $_GLAB_PIPELINE_STATUS in
	success)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

_glab_pipeline_status_is_waiting_manual() {
	case $_GLAB_PIPELINE_STATUS in
	manual)
		return 0
		;;
	*)
		return 1
		;;
	esac
}
