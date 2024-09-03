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

    if [ -f "$canonical_path" ]; then
      log debug "[backup] Creating ephemeral copy for $path"
      mkdir -p "$(dirname "$ephemeral_path")"
      if [ -f "$ephemeral_path" ]; then
        log debug "[backup] Overwriting ephemeral copy for $path"
        if [ -r "$path" ]; then
          cp -f "$path" "$ephemeral_path"
        else
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
      if [ -r "$path" ]; then
        cp "$path" "$canonical_path"
      else
        $AUTHORIZE_COMMAND cp "$path" "$canonical_path"
      fi
    fi
  done
}
