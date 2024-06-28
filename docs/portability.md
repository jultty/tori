`tori`'s role is to manage your configuration files and installed packages, allowing you to transfer this configuration between different versions of an operating system or even between different Unix and Unix-like operating systems, provided they are presently supported.

Because the application is meant to manage the installation of packages for you, it would defeat its purpose for it to require any packages to already be installed in order to function. It must be a portable application with minimal dependencies, so it can perform its functions on brand new systems where very few packages have been installed and little to no configuration has been done.

To achieve this portability and independence, it is meant to run on a POSIX-compatible shell where POSIX utilities are available. If your system does not provide this, it is very unlikely `tori` will function.

Below is a list of assumptions made about what your system supports:

- shell
    - `local` keyword

- executables
    - `find`
    - `sed`
    - `date` with nanoseconds as `%N`
      - While nanoseconds support in `date` is not in the POSIX 2017 standard, it is used only when `$DEBUG` is set in the environment and is available on the currently supported systems (FreeBSD, Void Linux) and on the next operating system with planned support (Debian).
    - `env` at `/usr/bin/env`
        - While this may be an issue from a portability standpoint, hardcoding the path where `sh` is also poses another portability issue. A more robust way to find it would be desirable.

`tori` is currently only tested on the `sh` Almquist shell as shipped by FreeBSD and the `dash` Almquist shell as shipped by Void Linux.
