merge_files() {
  local base_files="$1"
  local strategy="${2:-tree}"

  if [ "$strategy" == tree ]; then
    log info "[merge_files] Merging with $strategy strategy"
    if ! file_scan_tree "$base_files"; then
      if ! file_merge_tree "$base_files"; then
        merge_files "$base_files"
      fi
    fi
  fi
}

file_scan_tree() {
  local base_files="$1"

  for file in $base_files; do
    local absolute_path="$(echo "$file" | sed 's/^base//')"
    local config_path="$CONFIG_ROOT/$file"

    if ! diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
      return 1
    fi
  done
  return 0
}

file_merge_tree() {
  local base_files="$1"
  local strategy=

  for file in $base_files; do
    log debug "[merge_tree] Processing $file"
    local absolute_path="$(echo "$file" | sed 's/^base//')"
    log debug "[merge_tree] Absolute path: $absolute_path"
    local config_path="$CONFIG_ROOT/$file"
    log debug "[merge_tree] Config path: $config_path"

    if diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
      log debug "[merge_tree] Files match"
    else
      log debug "[merge_tree] Files differ"
      local prompt_verb="Differs"
        local prompt_options="Overwrite system,Overwrite configuration,Show difference"
      if ! [ -f "$absolute_path" ]; then
        local prompt_verb="In configuration only"
        local prompt_options="Copy to system"
      fi
      strategy="$(ask "$prompt_verb: $(tildify "$absolute_path")" "$prompt_options")"
      log debug "[merge_tree] Chosen strategy: $strategy"

      if [ "$strategy" -eq 0 ]; then
        return 0
      elif [ "$strategy" -eq 1 ]; then
        backup_paths "$absolute_path"
        cp -vi "$config_path" "$absolute_path"
        return 1
      elif [ "$strategy" -eq 2 ]; then
        backup_paths "$config_path"
        cp -vi "$absolute_path" "$config_path"
        return 1
      elif [ "$strategy" -eq 3 ]; then
        echo "< $(tildify "$absolute_path") | $(echo "$config_path" | sed "s*$CONFIG_ROOT/**") >"
        diff "$absolute_path" "$config_path"
        return 1
      else
        log user 'Invalid choice'
        return 1
      fi
    fi
  done
}
