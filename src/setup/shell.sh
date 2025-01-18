set_opts() {
    local target="$1"
    local sign=

    if [ "$target" = on ]; then
        sign='-'
    elif [ "$target" = off ]; then
        sign='+'
    else
        log fatal "Invalid set_opts target: $target. Expected on or off"
        return 1
    fi

    set_opt() {
        local opt="$1"

        if set -o | grep -q "^$opt[[:space:]]"; then
            set "${sign}o" "$opt"
            log debug "[set_opts] Set: $(set -o | grep "^$opt[[:space:]]")"
        else
            log fatal "Unsupported shell: no $opt option support"
            return 1
        fi
    }

    set_opt errexit
    set_opt nounset
}
