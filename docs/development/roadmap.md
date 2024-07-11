To do:

- When deciding to install/uninstall packages, there should be the option to also add/remove them from the configuration, both interactively and non-interactively

- Make configurable:
  - authorizer command (sudo/doas/su)
  - package cache update frequency (currently defaults to daily)

- Add a `--break` flag to the `log` function to print a newline before any output
    - Add this flag to the `log debug "user:\n$user_packages"` call on `scan_packages()` in `configuration.sh`

- Add install, uninstall and query commands to check the status of packages and simultaneously add/remove to/from system and configuration
    - Once install/uninstall and add/remove to/from configuration conflict resolution strategies have been implemented, the same functions can be reused to implement this
