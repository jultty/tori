# takes a list of newline-separated absolute paths
# backs each path up, creating canonical or ephemeral copies as needed
backup_paths() {
  local paths="$1"
  local canonical_path=
  local ephemeral_path=

  for path in $paths; do
    canonical_path="$BACKUP_ROOT/canonical$path"
    timestamp="$(date +'%Y-%m-%dT%H-%M-%S')"
    ephemeral_path="$BACKUP_ROOT/ephemeral${path}_$timestamp"

    log debug "[backup] Processing path $path"

    if [ -f "$canonical_path" ]; then
      log debug "[backup] Creating ephemeral copy for $path"
      mkdir -p "$(dirname "$ephemeral_path")"
      if [ -f "$ephemeral_path" ]; then
        log debug "[backup] Overwriting ephemeral copy for $path"
        if [ -r "$path" ]; then
          cp -f "$path" "$ephemeral_path"
        else
          # here it is still unknown if $path exists
          $AUTHORIZE_COMMAND cp -f "$path" "$ephemeral_path"
        fi
      else
        if [ -r "$path" ]; then
          cp "$path" "$ephemeral_path"
        else
          $AUTHORIZE_COMMAND cp "$path" "$ephemeral_path"
        fi
      fi
    else
      log debug "[backup] Creating canonical copy for $path"
      mkdir -p "$(dirname "$canonical_path")"

      # if $path exists and there is permission to read it
      if [ -r "$path" ]; then
        cp "$path" "$canonical_path"
      else
        # here it is still unknown if $path exists
        # if there is permission to browse the parent directory of $path
        if [ -x "$(dirname "$path")" ]; then
          # if $path does not exist
          if ! [ -f "$path" ]; then
            log info "[backup] Skipping canonical backup for $path: file not found in the system"
          else
            log warn "[backup] Unexpected control flow while seeking $path: existing file uncaught by upper condition"
          fi
        else
          # there is no way to browse the parent directory to determine if file exists
          if $AUTHORIZE_COMMAND stat "$path" > /dev/null 2>&1; then
            $AUTHORIZE_COMMAND cp "$path" "$canonical_path"
          else
            log info "[backup] Skipping canonical backup for $path: file not found in the system"
          fi
        fi
      fi

    fi
  done

  log debug "[backup] Done backing up all paths"
}
