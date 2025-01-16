# check command as executed by 'tori check'

check() {
    base_files=$(scan_directory "$CONFIG_ROOT/base")

    log debug "collected base files:\n$base_files"

    merge_files "$base_files"
    scan_packages "$CONFIG_ROOT/packages" || resolve_packages
}
