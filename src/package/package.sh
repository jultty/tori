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
		printf "$output"
	fi
}

get_system_packages() {
	local packages=$(package_manager get_manually_installed)
	printf "$packages"
}
