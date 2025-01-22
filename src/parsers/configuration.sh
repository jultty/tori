# configuration processing functions
# these functions serve as an interface between configuration files and inner logic

# takes a directory as its single argument
# returns the relative paths for each file contained within, separated by newlines
# only regular files are returned, symbolic links are not followed
scan_directory() {
    local target="$1"
    local files=
    local escaped_config_root

    escaped_config_root=$(echo "$CONFIG_ROOT" | sed 's/\//\\\//g')

    if [ -d "$target" ]; then
        scan=$(find "$target" -type f)
        for line in $scan; do
            line=$(echo "$line" | sed "s/$escaped_config_root\///")
            files="$line\n$files"
        done
    fi

    printf "%b" "$files"
}

# takes a path to a package list file
# returns 0 if packages match, 1 if they differ
scan_packages() {
    package_file="$1"

    if ! [ -f  "$package_file" ]; then
        log debug "[scan_packages] Skipping: no packages file"
        return 0
    fi

    system_packages=$(package_manager get_manually_installed)
    user_packages=$(cat "$package_file" | sort | uniq)

    if [ "$system_packages" = "$user_packages" ]; then
        log debug "[scan_packages] Packages match"
        return 0
    else
        log user "System and configuration packages differ"
        return 1
    fi
}
