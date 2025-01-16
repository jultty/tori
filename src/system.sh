get_operating_system() {
    local uname_output=$(uname -s)
    local os_release_name=$(cat /etc/os-release |
        grep '^NAME=' | sed 's/NAME=//' | sed 's/"//g')
    local os_release_id=$(cat /etc/os-release | grep '^ID=' | sed 's/ID=//')

    log debug "uname OS: $uname_output"
    log debug "os-release name: $os_release_name"
    log debug "os-release ID: $os_release_id"

    if [ "$os_release_name" = FreeBSD ]; then
        echo "FreeBSD"
        return 0
    elif [ "$os_release_name" = Void ]; then
        echo "Void"
        return 0
    else
        log fatal "Unsupported operating system"
        return 1
    fi
}
