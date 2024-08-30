merge_files() {
  local base_files="$1"
  local strategy="${2:-tree}"

  if [ "$strategy" == tree ]; then
    log info "[merge_files] Merging with $strategy strategy"
    if ! file_scan_tree "$base_files"; then
      file_merge_tree "$base_files"
      log info "[merge_files] Recursing"
      merge_files "$base_files"
    fi
  fi
}

file_scan_tree() {
  local base_files="$1"

  for file in $base_files; do
    local absolute_path="$(echo "$file" | sed 's/^base//')"
    local config_path="$CONFIG_ROOT/$file"

    if ! diff "$absolute_path" "$config_path" > /dev/null; then
      return 1
    fi
  done
  return 0
}

# TODO Check if files exist before acting
file_merge_tree() {
  local base_files="$1"
  local strategy=

  for file in $base_files; do
    log debug "[merge_tree] Processing $file"
    local absolute_path="$(echo "$file" | sed 's/^base//')"
    log debug "[merge_tree] Absolute path: $absolute_path"
    local config_path="$CONFIG_ROOT/$file"
    log debug "[merge_tree] Config path: $config_path"

    if diff "$absolute_path" "$config_path" > /dev/null; then
      log debug "[merge_tree] Files match"
    else
      log debug "[merge_tree] Files differ"
      strategy="$(ask "Differs: $(tildify "$absolute_path")" \
        "Overwrite system,Overwrite configuration,Show difference")"
      log debug "[merge_tree] Chosen strategy: $strategy"

      if [ "$strategy" -eq 1 ]; then
        cp -vi "$config_path" "$absolute_path"
      elif [ "$strategy" -eq 2 ]; then
        cp -vi "$absolute_path" "$config_path"
      elif [ "$strategy" -eq 3 ]; then
        echo "< $(tildify "$absolute_path") | $(echo "$config_path" | sed "s*$CONFIG_ROOT/**") >"
        diff "$absolute_path" "$config_path" || return 0
      else
        log user 'Invalid choice'
      fi
    fi
  done
}
