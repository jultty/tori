# configuration processing functions

scan_directory() {
  local target="$1"
  local files=
  local escaped_config_root

  escaped_config_root="$(echo "$CONFIG_ROOT" | sed 's/\//\\\//g')"

  if [ -d "$target" ]; then
    scan="$(find "$target" -type f)"
    for line in $scan; do
      line="$(echo "$line" | sed "s/$escaped_config_root\///")"
      files="$line\n$files"
    done
  fi

  printf "%b" "$files"
}

scan_packages() {

  if ! [ -f "$CONFIG_ROOT/packages" ]; then
    log debug "No packages file found in $CONFIG_ROOT"
    return 1
  fi

  system_packages="$(package_manager get_manually_installed)"
  user_packages="$(get_user_packages)"

  if [ "$system_packages" = "$user_packages" ]; then
    log debug "Packages match"
  else
    log user "System and configuration packages differ"
    resolve_packages
  fi
}

get_user_packages() {
  cat "$CONFIG_ROOT/packages" | sort | uniq
}
