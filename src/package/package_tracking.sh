# functions to track, untrack and query tracked state of packages

# returns 0 if all packages are tracked, 1 if any is untracked
query_packages() {
  local packages="$1"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    if ! cat "$CONFIG_ROOT/packages" | grep -q "^$package$"; then
      return 1
    fi
    return 0
  done
}

track_packages() {
  local packages="$1"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    if query_packages "$package"; then
      log info "Package $package was not tracked because it is already tracked"
    else
      echo "$package" >> "$CONFIG_ROOT/packages"
    fi
  done
}

untrack_packages() {
  local packages="$1"

  log info "[untrack_packages] Removing packages: $packages"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    sed -i '' "/^[[:space:]]*$package[[:space:]]*$/d" "$CONFIG_ROOT/packages"
    log info "[untrack_packages] Executed removal for $package with exit code $?"
  done
}
