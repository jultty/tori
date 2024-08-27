check() {
  base_files="$(scan_directory "$CONFIG_ROOT/base")"
  bkp_files="$(scan_directory "$CONFIG_ROOT/bkp")"

  log debug "collected base files:\n$base_files"
  log debug "collected bkp files:\n$bkp_files"

  scan_packages
  merge_base "$base_files"
}
