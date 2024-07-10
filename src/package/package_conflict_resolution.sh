resolve_packages() {
  local strategy=

  echo "$system_packages" > "$TMP_DIR/system_packages"
  echo "$user_packages" > "$TMP_DIR/user_packages"

  local not_on_configuration="$(grep -v -x -f "$TMP_DIR/user_packages" "$TMP_DIR/system_packages" | xargs)"
  local not_installed=$(grep -v -x -f "$TMP_DIR/system_packages" "$TMP_DIR/user_packages" | xargs)

  if [ -n "$not_on_configuration" ]; then

    printf "\nInstalled packages not on configuration: %s\n" "$not_on_configuration"
    echo "  [1] Uninstall all"
    echo "  [2] Enter packages to uninstall"
    echo "  [3] Add all to configuration"
    echo "  [4] Enter packages to add to configuration"
    echo "  [5] Decide on editor"
    echo "  [6] Cancel"

    read -r -p "Choose an option [1-6]: " strategy
    log debug "Input: strategy = $strategy"

    if [ -z "$strategy" ] || [ "$strategy" -eq 6 ]; then
      log debug "[resolve_packages] User choice: Cancel or empty"
    elif [ "$strategy" = 1 ]; then
      package_manager uninstall "$not_on_configuration"
    else
      log debug "[resolve_packages] Unexpected input: $strategy"
    fi
  fi

  if [ -n "$not_installed" ]; then

    printf "\nPackages on configuration but not installed: %s\n" "$not_installed"
    echo "  [1] Install all"
    echo "  [2] Enter packages to install"
    echo "  [3] Remove all from configuration"
    echo "  [4] Enter packages to remove from configuration"
    echo "  [5] Decide on editor"
    echo "  [6] Cancel"

    read -r -p "Choose an option [1-6]: " strategy
    log debug "Input: strategy = $strategy"

    if [ -z "$strategy" ] || [ "$strategy" -eq 6 ]; then
      log debug "[resolve_packages] User choice: Cancel or empty"
    elif [ "$strategy" -eq 1 ]; then
      package_manager install "$not_installed"
    else
      log debug "[resolve_packages] Unexpected input: $strategy"
    fi
  fi
}
