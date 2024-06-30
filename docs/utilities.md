The utilities functions available at `src/utility.sh` provide functionality that is either very simple in purpose or general to the whole application.

The two utility functions presently implemented are:

1. `log <level> <message>`
2. `prepare_directories`

## `log`

This utility takes a log level as its first argument and a message as its second argument. The log message must be wrapped in double quotes, otherwise only the first word will be considered part of the message and the rest will be discarded.

The current log levels are:
- `debug`: Displays only when `DEBUG` is set in the environment with a nanosecond-precision timestamp. The value `DEBUG` is set to does not matter. To disable the log messages, unset `DEBUG`, for example, with `export DEBUG=` or `unset DEBUG`
- `user`: Always displays, with `[tori]` at the very left followed by a second-precision timestamp, a colon and the message
- `fatal`: Always displays, exactly as in the `user` level

For now, all log messages are printed to `STDERR` so as not to shadow function return values.

## `prepare_directories`

`prepare_directories` runs at the very start of execution in order to verify that critical directories exist. These directories are:

- `TMP_DIR`, default `/tmp/tori`: created if not found
- `CONFIG_ROOT`, default `~/.config/tori`: application exits with an error and exit code 1 if not found
