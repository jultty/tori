# tests

These tests are meant to be run on a dedicated, temporary environment that is isolated and created only to run tests. They will use non-interactive options that overwrite system files without prompting.

The test scripts will:
1. create a configuration
2. run tori to apply the configuration to the running system
3. confirm through checksums that the produced system state matches the expected state
4. optionally perform additional modifications to the configuration or to the system through the tori CLI
5. optionally repeat steps 4 and then 3, one or more times

These tests will only test the tori command line options and configuration files. They do not test interactive use. However, it should be noted that both interactive and CLI use operate behind the same interfaces, meaning passing a CLI option should be the same as making a choice in an interactive dialog. The cause behind any unexpected effect should be strictly within the outer boundary where interactive dialog inputs and CLI options are interpreted, not in the inner logic where system modifications happen.

## Dependencies

- All scripts run under a POSIX shell
  - see <https://tori.jutty.dev/docs/development/portability.html>

Non-POSIX dependencies:
- tree (output only)
- sha256sum (input and output)
