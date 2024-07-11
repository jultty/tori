`tori`'s role is to manage your configuration files and installed packages, allowing you to transfer this configuration between different versions of an operating system or even between different Unix and Unix-like operating systems, provided they are presently supported.

Because the application is meant to manage the installation of packages for you, it would defeat its purpose for it to require any packages to already be installed in order to function. It must be a portable application with minimal dependencies, so it can perform its functions on brand new systems where very few packages have been installed and little to no configuration has been done.

To achieve this portability and independence, it is meant to run on a POSIX-compatible shell where POSIX utilities are available. If your system does not provide this, it is very unlikely `tori` will function.

Note that while `tori` expects a POSIX _shell_, it is not meant as a universal tool able to run on any POSIX system. A POSIX shell is required because it is the interpreter for the whole source code in which tori was implemented, but for some of its purposes `tori` needs to be running in a supported operating system. For example, it has specific package management features that work by abstracting the actual package manager options behind a function that detects the operating system and then runs the apropriate command.

While it strives to do so, in some situations, tori may perform tasks by relying on resources not specified by POSIX, such as when there is no option or the available option has readability or usability downsides. In these situations, tori tends to rely on specific functions that will switch their behavior depending on the operating system's support for the operation.

Below is a list of assumptions made about what your system supports:

- shell
    - `local`
    - `read` with `read -r -p <prompt> <variable_with_user_input>` syntax
    - `mkdir` with `-pggjj
    - `find`
    - `grep`
    - `sed`
    - `xargs`
    - `uname`
    - `date`
      - with nanoseconds as `%N`
        - While nanoseconds support in `date` is not in the POSIX 2017 standard, it is used only when `$DEBUG` is set in the environment and is available on the currently supported systems (FreeBSD, Void Linux) and on the next operating system with planned support (Debian).
      - with `-r` for getting a modification date
        - This feature is not specified on POSIX. So far it was tested on FreeBSD and Void Linux.
    - `env` at `/usr/bin/env`
        - While this may be an issue from a portability standpoint, hardcoding the path where `sh` is also poses another portability issue. A more robust way to find it would be desirable.

`tori` is currently only tested on the `sh` Almquist shell as shipped by FreeBSD and the `dash` Almquist shell as shipped by Void Linux.
