# Merges files using a given strategy and a given set of overwrite choices
# Receives three arguments:
# 1 : a list of files from the config/base directory which may be all of them or a subset
# 2 : name of a merging strategy (e.g., tree)
# 3 : colon-separated list of overwrite choices, with leading and trailing colons (e.g., :prefer-config:)
# Example: merge_files "$files" tree :prefer-system:
# Returns: a list obtained from file_scan_tree of differing files if it does not have enough information to merge them
#          (e.g., lacking overwrite choices), allowing the caller (e.g., check) to pass this list to the user and ask
#          them how to proceed;
#          nothing if it has enough information to merge them, which signals that merging did take place

merge_files() {
    local base_files="$1"
    local strategy="$2"
    local overwrite_choices="$3"

    log info "[merge_files] Merging with $strategy strategy"

    if [ "$strategy" = tree ]; then

        differing_files=$(file_scan_tree "$base_files")

        if [ -n "$differing_files" ]; then
            if [ -n "$overwrite_choices" ]; then
                file_merge_tree "$base_files" "$overwrite_choices"
            else
                echo "$differing_files"
            fi
        fi
    fi
}

# Assembles a list of base files that have differing counterparts in the system
# Receives one argument:
# 1 : a list of files from the config/base directory, all of them or a subset
# Example: file_scan_tree "$files"
# Returns: a list of differing files if it does find any;
#          nothing if it has found no differing files

file_scan_tree() {
    local base_files="$1"
    local differing_files=

    for file in $base_files; do
        local absolute_path
        absolute_path=$(echo "$file" | sed 's/^base//')
        local config_path="$CONFIG_ROOT/$file"

        if ! diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
            differing_files="$differing_files\n$file"
        fi
    done

    echo "$differing_files"
}

# Merges a list of files from the base config directory with their corresponding system versions
# Receives two arguments:
# 1 : a list of files from the config/base directory which may be all of them or a subset
# 2 : colon-separated list of overwrite choices, with leading and trailing colons (e.g., :prefer-config:)
# Example: file_merge_tree "$files" :prefer-system:
# Exits fatally if given files to merge without enough information to merge them (e.g. missing overwrite choices)
file_merge_tree() {
    local base_files="$1"
    local overwrite_choices="$2"
    local overwrite_action=
    local overwrite_ask=true

    for file in $base_files; do
        log debug "[merge_tree] Processing $file"
        local absolute_path
        absolute_path=$(echo "$file" | sed "s/base//")
        log debug "[merge_tree] Absolute path: $absolute_path"
        local config_path="$CONFIG_ROOT/$file"
        log debug "[merge_tree] Config path: $config_path"

        if diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
            log debug "[merge_tree] Files match"
        else
            log debug "[merge_tree] Files differ"

            if check_option prefer-config "$overwrite_choices" ||
                check_option prefer-system "$overwrite_choices"; then

                log debug "[file_merge_tree] Found non-interactive options "
                overwrite_ask=false

                if check_option prefer-config "$overwrite_choices"; then
                    overwrite_action=overwrite_system
                elif check_option prefer-system "$overwrite_choices"; then
                    overwrite_action=overwrite_config
                else
                    log fatal "[file_merge_tree] Unexpected control flow due to check_option output"
                fi

            else
                log fatal "[file_merge_tree] Not enough information to merge: missing overwrite choices"
                exit 1 # TODO Not exiting here
            fi

            if [ "$overwrite_action" = exit ]; then
                return 0
            elif [ "$overwrite_action" = overwrite_system ]; then
                backup_paths "$absolute_path"
                if [ -r "$config_path" ] && [ -w "$(dirname "$absolute_path")" ]; then
                    if [ $overwrite_ask = false ]; then
                        cp -vf "$config_path" "$absolute_path"
                    elif [ $overwrite_ask = true ]; then
                        cp -vi "$config_path" "$absolute_path"
                    else
                        log fatal "[merge_tree] Expected $overwrite_ask to be either true or false"
                    fi
                else
                    # this assumes the directories exist
                    $AUTHORIZE_COMMAND cp -vi "$config_path" "$absolute_path"
                fi
            elif [ "$overwrite_action" = overwrite_config ]; then
                backup_paths "$config_path"
                if [ -r "$absolute_path" ] && [ -w "$(dirname "$config_path")" ]; then
                    if [ $overwrite_ask = false ]; then
                        cp -vf "$absolute_path" "$config_path"
                    elif [ $overwrite_ask = true ]; then
                        cp -vi "$absolute_path" "$config_path"
                    else
                        log fatal "[merge_tree] Expected $overwrite_ask to be either true or false"
                    fi
                else
                    # this assumes the directories exist
                    $AUTHORIZE_COMMAND cp -vi "$absolute_path" "$config_path"
                fi
            elif [ "$overwrite_action" = show_diff ]; then
                echo "< $(tildify "$absolute_path") | $(echo "$config_path" | sed "s*$CONFIG_ROOT/**") >"
                if [ -r "$absolute_path" ] && [ -r "$config_path" ]; then
                    diff "$absolute_path" "$config_path"
                else
                    # TODO this assumes the files exist, and are just not readable, but they may not exist at all
                    $AUTHORIZE_COMMAND diff "$absolute_path" "$config_path"
                fi
            else
                log user "[file_merge_tree] Invalid overwrite choices (action: $overwrite_action, ask: $overwrite_ask)"
                return 1
            fi
        fi
    done
}
