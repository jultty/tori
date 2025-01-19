permission_aware_copy() {
    local source="$1"
    local destination="$2"
    local options="$3"

    if [ -r "$source" ]; then
        # shellcheck disable=SC2086
        cp -$options "$source" "$destination"
    else
        log user "Need root permissions to backup $source"
        # shellcheck disable=SC2086
        $AUTHORIZE_COMMAND cp -$options "$source" "$destination"
    fi
}

# takes a list of newline-separated absolute paths
# backs each path up, creating canonical or ephemeral copies as needed
# TODO make ephemeral backups based on checksums, not timestamps
backup_paths() {
    local paths="$1"
    local canonical_path=
    local ephemeral_path=

    log debug "[backup] Processing paths $paths"

    for path in $paths; do
        canonical_path="$BACKUP_ROOT/canonical$path"
        timestamp=$(date +'%Y-%m-%dT%H-%M-%S')
        ephemeral_path="$BACKUP_ROOT/ephemeral${path}_$timestamp"

        log debug "[backup] Processing path $path"

        # If this path does not exist in the system, skip this file
        if [ -x "$(dirname "$path")" ]; then
            # We can browse the directory containing $path
            if [ -r "$path" ]; then
                # We can read $path
                log debug "[backup] Read access to $path"
            elif [ -f "$path" ]; then
                # We can see $path, but not read it
                log debug "[backup] No read access to existing $path"
            else
                log info "[backup] Skipping backup for $path: not found on the system"
                continue
            fi
        else
            # We can not browse the directory containing $path
            log debug "[backup] No access to directory $(dirname "$path") containing target backup file $path"
            log user "Need root permissions to prepare $path for backup"
            if $AUTHORIZE_COMMAND stat "$path" > /dev/null 2>&1; then
                log debug "[backup] Succesfully stated root-accessible $path"
            else
                log info "[backup] Skipping backup for $path: not found on the system"
                continue
            fi
        fi

        # If this path already has a canonical backup, create an ephemeral one
        if [ -f "$canonical_path" ]; then

            log debug "[backup] Creating ephemeral copy for $path"
            mkdir -p "$(dirname "$ephemeral_path")"

            # If an ephemeral path for the same second already exists, overwrite it
            if [ -f "$ephemeral_path" ]; then
                log debug "[backup] Overwriting ephemeral copy for $path"
                    permission_aware_copy "$path" "$ephemeral_path" f

            # If an ephemeral path for the same second does not exist, create it
            else
                permission_aware_copy "$path" "$ephemeral_path"
            fi

        # If this path has no canonical backup, create one
        else
            log debug "[backup] Creating canonical copy for $path"
            mkdir -p "$(dirname "$canonical_path")"
            permission_aware_copy "$path" "$canonical_path"
        fi
    done

    log debug "[backup] Done backing up all paths"
}
