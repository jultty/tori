validate_input_packages() {
  local package_list="$1"
  local invalid_characters_pattern=

  if [ "$OS" = FreeBSD ]; then
    invalid_characters_pattern='[^A-Za-z0-9\+_\.-]'
  fi

  echo "$package_list" | xargs | sed 's/ /\n/g' | while read -r package; do

    if echo "$package" | grep -q "$invalid_characters_pattern"; then
      log user "Invalid package: $package (contains invalid characters)"
      return 1
    fi
    if grep -qw "$package" "$PACKAGE_CACHE"; then
      log debug "Found in package cache: $package"
    else
      log user "Invalid package: $package (not found in package cache)"
      return 1
    fi
  done
}
