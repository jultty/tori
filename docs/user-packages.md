In order to take advantage of all the features offered by `tori` for package management, the operating system's package manager must provide a way to:

- install and uninstall packages from a command-line interface
- query manually installed packages

The `packages` file is located at the root of the configuration directory and contains a list of package names, one per line. Blank lines and lines beginning with `#` are ignored.

When processing the package list, `tori` will compare the list of installed packages to the list in the configuration and ask the user for what action to take in order to conciliate them, unless a default action has been specified.

For information on how the application determines differences between the configuration package list and the actually installed packages, see [`check`](check).
