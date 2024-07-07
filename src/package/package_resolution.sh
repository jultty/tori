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
		elif [ $strategy -eq 6 ]; then
			return 0
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
		elif [ $strategy -eq 6 ]; then
			return 0
		fi
	fi
}
