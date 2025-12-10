_is_supported_platform() {
	case $_DETECTED_PLATFORM in
	$_PLATFORM)
		return 0
		;;
	*)
		printf '%s\n' "$SUPPORTED_PLATFORMS" | tr ' ' '\n' | grep -cqm1 "^$_DETECTED_PLATFORM$" && {
			_ERROR "Please use the appropriate platform application: ($_DETECTED_PLATFORM)"
		}

		_ERROR "Unsupported platform ($_DETECTED_PLATFORM)"
		;;
	esac
}
