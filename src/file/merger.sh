# TODO update this description
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
    local strategy="$1"
    local orders="$2"

    local base_files
    base_files=$(echo "$orders" | cut -f 2 -d ' ')

    log info "[merge_files] Merging with $strategy strategy"

    if [ "$strategy" = tree ]; then

        differing_files=$(file_scan_tree "$base_files")

        if [ -n "$differing_files" ]; then
            if file_merge_tree "$orders"; then
                log debug "[merge_files] Files merged"
            else
                echo "$differing_files"
            fi
        else
            log debug "[merge_files] No differing files"
        fi
    fi
}

# TODO update this description
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

    log debug file_scan_tree "Found $(echo "$differing_files" | wc -l) differing files"
    echo "$differing_files"
}

# TODO update this description
# Merges a list of files from the base config directory with their corresponding system versions
# Receives two arguments:
# 1 : a list of files from the config/base directory which may be all of them or a subset
# 2 : colon-separated list of overwrite choices, with leading and trailing colons (e.g., :prefer-config:)
# Example: file_merge_tree "$files" :prefer-system:
# Exits fatally if given files to merge without enough information to merge them (e.g. missing overwrite choices)
# Status:
# 1 : Overwrite options are insufficient or invalid

file_merge_tree() {
    local orders="$1"
    local overwrite_action=
    local overwrite_ask=true

    log debug file_scan_tree "Reading orders"

    printf "%b\n" "$orders" | while read -r options file tail; do
        if [ -n "$tail" ]; then
            log fatal file_merge_tree "Unexpected order segment $tail in order $options $file"
            return 1
        fi

        log debug "Found order $options $file"

        local absolute_path
        absolute_path=$(echo "$file" | sed "s/base//")
        log debug "[merge_tree] Absolute path: $absolute_path"
        local config_path="$CONFIG_ROOT/$file"
        log debug "[merge_tree] Config path: $config_path"

        if diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
            log debug "[merge_tree] Files match"
        else
            log debug "[merge_tree] Files differ"

            # TODO all cases, check existence and perms: read for left, write for right's directory
            if check_option overwrite-system "$options"; then
                backup_paths "$absolute_path"
                cp -vf "$config_path" "$absolute_path"
            elif check_option overwrite-config "$options"; then
                backup_paths "$config_path"
                cp -vf "$absolute_path" "$config_path"
            elif check_option prefer-config "$options"; then
                backup_paths "$absolute_path"
                cp -vi "$config_path" "$absolute_path"
            elif check_option prefer-system "$options"; then
                backup_paths "$config_path"
                cp -vi "$absolute_path" "$config_path"
            elif check_option show-diff "$options"; then

                # TODO extract the logic below to a function check_exists that takes two paths,
                #      also making a similar one that works similarly but checks that one of the paths
                #      exist. use these functions to solve the TODO above

                echo "< $(tildify "$absolute_path") | $(echo "$config_path" | sed "s*$CONFIG_ROOT/**") >"

                if [ -r "$absolute_path" ] && [ -r "$config_path" ]; then
                    diff "$absolute_path" "$config_path"
                elif ! [ -f "$absolute_path" ] && [ -f "$config_path" ]; then
                    log user "Can't diff files: $absolute_path does not exist"
                elif ! [ -f "$config_path" ] && [ -f "$absolute_path" ]; then
                    log user "Can't diff files: $config_path does not exist"
                elif ! [ -f "$config_path" ] && ! [ -f "$absolute_path" ]; then
                    log user "Can't diff files: neither file exists"
                else
                    log user "Need root privilege to diff files"
                    sh_out=$($AUTHORIZE_COMMAND sh -c "

                        if ! stat \"$absolute_path\" > /dev/null 2>&1; then
                            echo not found: absolute
                        elif ! stat \"$config_path\" > /dev/null 2>&1; then
                            echo not found: config
                        else
                            diff \"$absolute_path\" \"$config_path\"
                        fi

                    ")

                    if [ "$sh_out" = "not found: absolute" ]; then
                        log user "Can't diff files: $absolute_path does not exist"
                    elif [ "$sh_out" = "not found: absolute" ]; then
                        log user "Can't diff files: $config_path does not exist"
                    else
                        printf '%b' "$sh_out"
                    fi
                fi

            else
                log debug file_merge_tree "Not enough information to merge: missing overwrite choices"
                return 1
            fi

        fi

    done
}
