track_packages() {
  local packages="$1"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    echo "$package" >> "$CONFIG_ROOT/packages"
  done
}

untrack_packages() {
  local packages="$1"

  log info "[untrack_packages] Removing packages: $packages"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    updated_packages=$(sed "/^[[:space:]]*$package[[:space:]]*$/d" "$CONFIG_ROOT/packages")
    echo "$updated_packages" > "$CONFIG_ROOT/packages"
    log info "[untrack_packages] Executed removal for $package"
  done
}
