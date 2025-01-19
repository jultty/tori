# check command as executed by 'tori check'

check() {
    local user_options="$1"
    local base_files=$(scan_directory "$CONFIG_ROOT/base")

    log debug "collected base files:\n$base_files"

    log debug "Merging files"

    local differing_files=$(merge_files "$base_files" tree "$user_options")

    if [ -n "$differing_files" ]; then
        log user "Differing files: $differing_files"
    fi

        # TODO ask for new user options if interactive,
        # include option to exit merging, which proceeds to package merging
        #
            #     local prompt_verb="Differs"
            #     local prompt_options="Overwrite system,Overwrite configuration,Show difference"
            #     if ! [ -f "$absolute_path" ]; then
            #         local prompt_verb="In configuration only"
            #         local prompt_options="Copy to system"
            #     fi
            #     overwrite_choice=$(ask "$prompt_verb: $(tildify "$absolute_path")" "$prompt_options")
            #
            #     case "$overwrite_choice" in
            #         0)
            #             overwrite_action='exit'
            #             ;;
            #         1)
            #             overwrite_action=overwrite_system
            #             ;;
            #         2)
            #             overwrite_action=overwrite_config
            #             ;;
            #         3)
            #             overwrite_action=show_diff
            #             ;;
            #         *)
            #             log fatal "[file_merge_tree] Unexpected output from ask: overwrite_choice=$overwrite_choice"
            #             ;;
            #     esac
            #
            #     overwrite_ask=true
            #
            #     log debug "[merge_tree] Interactive overwrite choice: $overwrite_choice"
            # fi
        #
        # user_options=

    log debug "Files merged"

    scan_packages "$CONFIG_ROOT/packages" || resolve_packages
}
