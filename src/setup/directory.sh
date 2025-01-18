prepare_directories() {
    if ! [ -d "$TMP_ROOT" ]; then
        mkdir "$TMP_ROOT"
    fi

    if ! [ -d "$CACHE_ROOT" ]; then
        mkdir -p "$CACHE_ROOT"
    fi

    if ! [ -d "$BACKUP_ROOT" ]; then
        mkdir -p "$BACKUP_ROOT"
        if ! [ -d "$BACKUP_ROOT/canonical" ]; then
            mkdir "$BACKUP_ROOT/canonical"
        fi
        if ! [ -d "$BACKUP_ROOT/ephemeral" ]; then
            mkdir "$BACKUP_ROOT/ephemeral"
        fi
    fi

    if ! [ -d "$CONFIG_ROOT" ]; then
        log fatal "Configuration root not found at $CONFIG_ROOT"
        exit 1
    fi
}
