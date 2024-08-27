merge_base() {
  local base_files="$1"
  local strategy=

  for file in $base_files; do
    log debug "[merge-base] Processing $file"
    local absolute_path="$(echo "$file" | sed 's/^base//')"
    log debug "[merge-base] Absolute path: $absolute_path"
    local config_path="$CONFIG_ROOT/$file"
    log debug "[merge-base] Config path: $config_path"

    if diff "$absolute_path" "$config_path" > /dev/null; then
      log debug "[merge-base] Files match"
    else
      log debug "[merge-base] Files differ"
      strategy="$(ask "Configuration and system files differ" "Overwrite system,Overwrite config,Show difference")"
      log debug "[merge-base] Chosen strategy: $strategy"
    fi
  done
}
