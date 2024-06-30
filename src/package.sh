# package management functions

get_user_packages() {
	cat $CONFIG_ROOT/packages | sort | uniq
}

package_manager() {
	local command="$1"
	local manager
	local args__get_manually_installed
	local output

	if [ $OS = "FreeBSD" ]; then
		manager="pkg"
		args__get_manually_installed='query -e "%a = 0" "%n"'
	fi

	if [ "$command" = 'get_manually_installed' ]; then
		output=$(eval $manager $args__get_manually_installed)
		log debug "package.package_manager returning: $output"
		printf "$output"
	fi
}

get_system_packages() {
	local packages=$(package_manager get_manually_installed)
	log debug "package.get_system_packages returning: $packages"
	printf "$packages"
}

resolve_packages() {
	local strategy=

	echo "$system_packages" > "$TMP_DIR/system_packages"
	echo "$user_packages" > "$TMP_DIR/user_packages"

	local not_on_configuration="$(grep -v -x -f "$TMP_DIR/user_packages" "$TMP_DIR/system_packages" | xargs)"
	local not_installed=$(grep -v -x -f "$TMP_DIR/system_packages" "$TMP_DIR/user_packages" | xargs)

	if [ -n "$not_on_configuration" ]; then

		printf "\nInstalled packages not on configuration: $not_on_configuration\n"
		echo "  [1] Uninstall all"
		echo "  [2] Enter packages to uninstall" 
		echo "  [3] Add all to configuration"
		echo "  [4] Enter packages to add to configuration"
		echo "  [5] Decide on editor"
		echo "  [6] Cancel"

		read -r -p "Choose an option [1-6]: " strategy
		log debug "Input: strategy = $strategy"

		if [ "$strategy" = 1 ]; then
			: # TODO
		fi
	fi

	if [ -n "$not_installed" ]; then

		printf "\nPackages on configuration but not installed: $not_installed\n"
		echo "  [1] Install all"
		echo "  [2] Enter packages to install"
		echo "  [3] Remove all from configuration"
		echo "  [4] Enter packages to remove from configuration"
		echo "  [5] Decide on editor"
		echo "  [6] Cancel"

		read -r -p "Choose an option [1-6]: " strategy
		log debug "Input: strategy = $strategy"

		if [ $strategy -eq 1 ]; then
			: # TODO
		fi
	fi
}
