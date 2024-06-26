tori is designed to be portable so that its features allow transfering your configuration between different versions of an operating system or even between different operating systems depending on the presently supported ones.

To aid this portability and ability to run in different systems, it is also designed to have minimal dependencies since it is meant to run on brand new systems where very few packages have been installed.

Despite this, some assumptions are still made about what your system supports:

- shell
    - `local` keyword

- executables
    - `find`
    - `date` with nanoseconds as `%N`
    - `env` at `/usr/bin/env`
        - While this may be an issue from a portability standpoint, hardcoding the path where `sh` is also poses another portability issue. A more robust way to find it would be desirable.

tori is implemented as a set of shell scripts. These are currently only tested on the `sh` Almquist shell as shipped by FreeBSD and the `dash` Almquist shell as shipped by Void Linux.
