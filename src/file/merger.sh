# TODO establish the following behavior:
#
# Merges files using a given strategy and a given set of overwrite choices
# Receives three arguments:
# 1 : a list of files from the config/base directory which may be all of them or a subset
# 2 : name of a merging strategy (e.g., tree)
# 3 : colon-separated list of overwrite choices, with leading and trailing colons (e.g., :prefer-config:) this may be
#     facilicated by extracting the code in parsers/option_parser that validates CLI arguments against contradictory options
# Example: merge_files "$files" tree :prefer-system:
# Returns: a list obtained from file_scan_tree of differing files if it does not have enough information to merge them
#          (e.g., lacking overwrite choices), allowing the caller (e.g., check) to pass this list to the user and ask
#          them how to proceed;
#          nothing if it has enough information to merge them, which signals that merging did take place

merge_files() {
    local base_files="$1"
    local strategy="${2:-tree}"

    log info "[merge_files] Merging with $strategy strategy"

    if [ "$strategy" = tree ]; then
        if ! file_scan_tree "$base_files"; then
            if ! file_merge_tree "$base_files"; then
                merge_files "$base_files"
            fi
        fi
    fi
}

# TODO establish the following behavior, considering performance would be gained if
# file_scan_tree returned a list of differing files, eliminating the need for
# file_merge_tree to compare all base_files again:
#
# Assembles a list of base files that have corresponding differing files in the system
# Receives one argument:
# 1 : a list of files from the config/base directory which may be all of them or a subset
# Example: file_scan_tree "$files"
# Returns: a list of differing files if it does find any;
#          nothing if it has found no differing files
# Status: 1 if differing files were found
#         0 if differing files were not found

file_scan_tree() {
    local base_files="$1"

    for file in $base_files; do
        local absolute_path=$(echo "$file" | sed 's/^base//')
        local config_path="$CONFIG_ROOT/$file"

        if ! diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
            return 1
        fi
    done
    return 0
}

# TODO should exit fatally if given files to merge without enough information to merge them (e.g. missing overwrite choices)
# TODO should not interact with the user at all
file_merge_tree() {
    local base_files="$1"
    local overwrite_choice=
    local overwrite_action=
    local overwrite_ask=true

    for file in $base_files; do
        log debug "[merge_tree] Processing $file"
        local absolute_path=$(echo "$file" | sed 's/^base//')
        log debug "[merge_tree] Absolute path: $absolute_path"
        local config_path="$CONFIG_ROOT/$file"
        log debug "[merge_tree] Config path: $config_path"

        if diff "$absolute_path" "$config_path" > /dev/null 2>&1; then
            log debug "[merge_tree] Files match"
        else
            log debug "[merge_tree] Files differ"

            # TODO check-option should no longer inspect global state, but always be given what options to check
            # TODO check-option maybe should also perform checks on contradictory options
            #      these are presently only checked by the option_parser, which parses user-supplied input, meaning
            #      such contradictions will go unchecked for internal use; consider extracting these checks
            if check_option prefer-config || check_option prefer-system; then
                log debug "[file_merge_tree] Found non-interactive options "
                if check_option prefer-config; then
                    overwrite_action=overwrite_system
                elif check_option prefer-system; then
                    overwrite_action=overwrite_config
                else
                    log fatal "[file_merge_tree] Unexpected control flow due to check_option output"
                fi

                overwrite_ask=false

            else
                local prompt_verb="Differs"
                local prompt_options="Overwrite system,Overwrite configuration,Show difference"
                if ! [ -f "$absolute_path" ]; then
                    local prompt_verb="In configuration only"
                    local prompt_options="Copy to system"
                fi
                overwrite_choice=$(ask "$prompt_verb: $(tildify "$absolute_path")" "$prompt_options")

                case "$overwrite_choice" in
                    0)
                        overwrite_action='exit'
                        ;;
                    1)
                        overwrite_action=overwrite_system
                        ;;
                    2)
                        overwrite_action=overwrite_config
                        ;;
                    3)
                        overwrite_action=show_diff
                        ;;
                    *)
                        log fatal "[file_merge_tree] Unexpected output from ask: overwrite_choice=$overwrite_choice"
                        ;;
                esac

                overwrite_ask=true

                log debug "[merge_tree] Interactive overwrite choice: $overwrite_choice"
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
                return 1
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
                return 1
            elif [ "$overwrite_action" = show_diff ]; then
                echo "< $(tildify "$absolute_path") | $(echo "$config_path" | sed "s*$CONFIG_ROOT/**") >"
                if [ -r "$absolute_path" ] && [ -r "$config_path" ]; then
                    diff "$absolute_path" "$config_path"
                else
                    $AUTHORIZE_COMMAND diff "$absolute_path" "$config_path"
                fi
                return 1
            else
                log user "[file_merge_tree] Invalid choice overwrite_action=$overwrite_action, overwrite_ask=$overwrite_ask"
                return 1
            fi
        fi
    done
}
