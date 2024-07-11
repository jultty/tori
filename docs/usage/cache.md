tori caches your package repository's list of all available packages in order to check if a given package name really corresponds to a package name available to install or uninstall.

This works by asking your package manager for this list and then storing it in the configured cache directory. It defaults to `~/.cache/tori/${OS}_packages.cache`. For example, on FreeBSD this will be `FreeBSD_packages.cache`.

The modification date of this file is accessed every time tori is launched. By default, if it differs from the current day it will trigger a refresh. Note that this is not a comparison on whether 24 hours have passed since the last refresh.

For this reason, tori may ask you for your password on startup with the message "Updating package cache".

If you would like to manually refresh the cache, you can use the `tori cache` command.
