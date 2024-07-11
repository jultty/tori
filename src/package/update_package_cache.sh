update_package_cache() {
  set_opts +
  local argument="$1"
  set_opts -

  if [ -f "$PACKAGE_CACHE" ]; then
    local last_update="$(date -r "$PACKAGE_CACHE" +%Y-%m-%d)"
  fi

  if ! [ -f "$PACKAGE_CACHE" ] || [ "$last_update" != "$(date -I)" ] || [ "$argument" = --force ]; then
    log user 'Updating package cache'
    if [ "$OS" = FreeBSD ]; then
      package_manager update
    fi
    package_manager get_available > "$PACKAGE_CACHE"
  else
    log debug "Skipping package cache refresh: last updated $last_update"
  fi
}
