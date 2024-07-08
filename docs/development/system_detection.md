tori determines what is the running operating system through the output of `uname -s`. If it cannot get a descriptive enough, it will look for the `/etc/os-release` file.

If a `/etc/os-release` file is present, it takes precedence over the output of `uname`. Both the `NAME` and `ID` values will be looked at. This is aimed at helping to disambiguate between different variants of the same operating system.

The `NAME` value may be the only queried value if for the given supported operating system it is enough to disambiguate between the variants tori needs to be aware of.

In case there is no `/etc/os-release` file found, the output of `uname` is the next value considered.

If a supported operating system is not detected on neither of these, tori will exit with an error.
