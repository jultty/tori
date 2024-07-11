This function takes a list of package names separated by spaces and verifies that:

- Characters are only:
- The package is a valid package name

## Character validation

An OS-specific pattern will be matched against the package name to decide which characters are valid or invalid by the naming standards its package repository uses.

If no OS-specific documentation is found on what are the allowed characters in package names, the obtained package list containing all available packages in the operating system's main repository will be analyzed to determine what is the current range of characters it uses.

The following character ranges have been determined so far:

- FreeBSD `pkg`
    - uppercase and lowercase letters
    - numbers
    - dashes
    - underscores
    - dots
    - plus signs

## Package validation

To determine if a package really exists, there must be a quick way to query a list of all available packages that does not mean individually making requests with each package name.

If the package manager provides a way to fetch a list of all available packages, tori will cache this list for each execution on a given day.

The user may also manually trigger a cache refresh through the command line interface using `tori cache`.
