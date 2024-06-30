# configuration processing functions

scan_directory() {
	local target="$1"
	local files=
	local escaped_config_root="$(echo $CONFIG_ROOT | sed 's/\//\\\//g')"

	if [ -d "$target" ]; then
		scan="$(find "$target" -type f)"
		for line in $scan; do
			line="$(echo $line | sed "s/$escaped_config_root\///")"
			files="$line\n$files"
		done
	fi

	echo "$files"
}

scan_packages() {

	system_packages="$(get_system_packages)"
	user_packages="$(get_user_packages)"

	if [ "$system_packages" = "$user_packages" ]; then
		log debug "packages match"
	else
		log debug "packages mismatch"
		log debug "system: $system_packages"
		log debug "user: $user_packages"

		log user "System and configuration packages differ"
		resolve_packages
	fi
}
