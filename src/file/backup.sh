# takes a list of space-separated absolute paths 
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
        cp -f "$path" "$ephemeral_path"
      else
        cp "$path" "$ephemeral_path"
      fi
    else
      log debug "[backup] Creating canonical copy for $path"
      mkdir -p "$(dirname "$canonical_path")"
      cp "$path" "$canonical_path"
    fi
  done
}
