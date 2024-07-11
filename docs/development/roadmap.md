To do:

- Add a `--break` flag to the `log` function to print a newline before any output
    - Add this flag to the `log debug "user:\n$user_packages"` call on `scan_packages()` in `configuration.sh`

- Add install, uninstall and query commands to check the status of packages and simultaneously add/remove to/from system and configuration
    - Once install/uninstall and add/remove to/from configuration conflict resolution strategies have been implemented, the same functions can be reused to implement this
