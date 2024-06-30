# utility functions

log() {
	local level="$1"
	local message="$2"

	if [ $level = fatal ]; then
		printf "[tori] $(date "+%H:%M:%S"): $message\n" 1>&2
	elif [ $level = user ]; then
		printf "[tori] $(date "+%H:%M:%S"): $message\n" 1>&2
	elif [ -n "$DEBUG" ] && [ $level = debug ]; then
		printf "$(date "+%H:%M:%N") $message\n" 1>&2
	fi
}

prepare_directories() {
	if ! [ -d "$TMP_DIR" ]; then
		mkdir "$TMP_DIR"
	fi

	if ! [ -d "$CONFIG_ROOT" ]; then
		log fatal "Configuration root not found at $CONFIG_ROOT"
		exit 1
	fi
}

