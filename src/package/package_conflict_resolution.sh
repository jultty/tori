resolve_packages() {
  local strategy=
  local input_packages=

  # shellcheck disable=SC2154
  ( echo "$system_packages" > "$TMP_DIR/system_packages"
    echo "$user_packages" > "$TMP_DIR/user_packages" )

  local packages_not_on_configuration="$(grep -v -x -f \
    "$TMP_DIR/user_packages" "$TMP_DIR/system_packages" | xargs)"

  if [ -n "$packages_not_on_configuration" ]; then
    not_on_configuration_dialog "$packages_not_on_configuration"
  fi

  local packages_not_installed=$(grep -v -x -f \
    "$TMP_DIR/system_packages" "$TMP_DIR/user_packages" | xargs)

  if [ -n "$packages_not_installed" ]; then
    not_installed_dialog "$packages_not_installed"
  fi
}

not_on_configuration_dialog() {
  local conflicted_packages="$1"
  local input_packages=

  printf "\nInstalled packages not on configuration: %s\n" "$conflicted_packages"
  echo "  [1] Uninstall all"
  echo "  [2] Enter packages to uninstall"
  echo "  [3] Add all to configuration"
  echo "  [4] Enter packages to add to configuration"
  echo "  [5] Decide on editor"
  echo "  [6] Cancel"

  read -r -p "Choose an option [1-6]: " strategy
  log debug "Input: strategy = $strategy"

  if [ "$strategy" = 6 ]; then
    log debug "[resolve_packages] User choice: Cancel or empty"
  elif [ "$strategy" = 1 ]; then
    package_manager uninstall "$conflicted_packages"
  elif [ "$strategy" = 2 ]; then
    read -r -p "Enter packages to uninstall separated by spaces: " input_packages
    log debug "Input: input_packages = $input_packages"
    if validate_input_packages "$input_packages"; then
      package_manager uninstall "$input_packages"
    else
      not_on_configuration_dialog "$conflicted_packages"
    fi
  elif [ "$strategy" = 3 ]; then
    track_packages "$conflicted_packages"
  elif [ "$strategy" = 4 ]; then
    read -r -p "Enter space-separated packages to add to the configuation: " input_packages
    log debug "Input: input_packages = $input_packages"
    track_packages "$input_packages"
  else
    log debug "[resolve_packages] Unexpected input: $strategy"
    not_on_configuration_dialog "$conflicted_packages"
  fi
}

not_installed_dialog() {
  local conflicted_packages="$1"
  local input_packages=

  printf "\nPackages on configuration but not installed: %s\n" "$conflicted_packages"
  echo "  [1] Install all"
  echo "  [2] Enter packages to install"
  echo "  [3] Remove all from configuration"
  echo "  [4] Enter packages to remove from configuration"
  echo "  [5] Decide on editor"
  echo "  [6] Cancel"

  read -r -p "Choose an option [1-6]: " strategy
  log debug "Input: strategy = $strategy"

  if [ "$strategy" = 6 ]; then
    log debug "[resolve_packages] User choice: Cancel or empty"
  elif [ "$strategy" = 1 ]; then
    package_manager install "$conflicted_packages"
  elif [ "$strategy" = 2 ]; then
    read -r -p "Enter packages to install separated by spaces: " input_packages
    log debug "Input: input_packages = $input_packages"
    if validate_input_packages "$input_packages"; then
      package_manager install "$input_packages"
    else
      not_on_configuration_dialog "$conflicted_packages"
    fi
  elif [ "$strategy" = 3 ]; then
    untrack_packages "$conflicted_packages"
  elif [ "$strategy" = 4 ]; then
    read -r -p "Enter space-separated packages to remove from the configuation: " input_packages
    log debug "Input: input_packages = $input_packages"
    untrack_packages "$input_packages"
  else
    log debug "[resolve_packages] Unexpected input: $strategy"
    not_installed_dialog "$conflicted_packages"
  fi
}
