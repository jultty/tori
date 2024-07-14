track_packages() {
  local packages="$1"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    echo "$package" >> "$CONFIG_ROOT/packages"
  done
}

untrack_packages() {
  local packages="$1"

  log debug "[untrack_packages] Removing packages: $packages"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    sed -i '' "/^[[:space:]]*$package[[:space:]]*$/d" "$CONFIG_ROOT/packages"
    log debug "[untrack_packages] Executed removal for $package with exit code $?"
  done
}
