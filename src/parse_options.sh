# Parses options from a full command line
# Receives two arguments:
# 1 : arbitrarily-ordered string containing space-separated command line arguments
# 2 : colon-separated long-form valid options without leading dashes
# Example: parse_options "check --prefer-system" 'check:prefer-config:prefer-system'
# Returns a string containing colon-separated dashless long-form valid found arguments
# Exits with 1 if provided options don't match the canon

parse_options() {
    local user_arguments="$1"
    local canon="$2"

    if echo "$user_arguments" | grep ':'; then
        log fatal "Arguments must not contain a colon (:) character"
        return 1
    fi

    log debug "[parse_arguments] Parsing user arguments $user_arguments"

    split_arguments=":$(echo "$user_arguments" | xargs |
        sed 's/ /\n/g' | sed -E 's/^-+//' | sort -h | xargs | sed 's/ /:/g'
    ):"

    log debug "[parse_arguments] Split arguments: $split_arguments"

    canon_regex=$(echo "$canon" | xargs | sed 's/ //g' | sed 's/:/|/g')

    log debug "Canonical arguments regex: $canon_regex"

    bad_args=$(echo "$split_arguments" |
        sed 's/:/\n/g' | grep -vE "$canon_regex")

    if [ -n "$bad_args" ]; then
        log fatal "Unrecognized arguments: $(echo "$bad_args" | xargs)"
        exit 1
    else
        echo "$split_arguments"
    fi
}
