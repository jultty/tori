`tori` can track if a given file in the configuration directory is present and matches the content of the corresponding file on the system level.

However, if a file changed on the system level is not in the configuration directory, `tori` can only alert you to that if the operating system provides some way to compare the present state of the system to the original one prior to user intervention.

One example would be FreeBSD's intrusion detection system, which provides a way to know which files have been changed. Another way would be by relying on a file system that provides the ability to compare differences between snapshots, such as ZFS. A third way would be if the operating system's package manager provides a command line interface to read the contents of packages and has packages that correspond to the core system, such as Void Linux's package manager, `xbps`.

The resource-intensiveness of each of these methods will vary greatly and therefore checking the whole system for changes can be time-consuming or provide overwhelming output. For this reason, `tori` by default operates in a more minimal fashion where you take responsibility for adding the files you would like to track to your configuration and only get warnings of untracked files when explicitly asked.
