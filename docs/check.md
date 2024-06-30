The `check` option performs two tasks through the configuration processing functions available at `src/configuration.sh`

1. Traverse the configuration directory to assemble a file list containing full paths for both the `base` and `bkp` directories
2. Compare the installed packages with the `packages` file at the root of the configuration directory

The first task is currently accomplished by resorting to `find`. While this allows for cleaner code, it relies on a utility with variable behavior across operating systems. Given the simplicity of the query, a better option might be using a POSIX-compliant wildcard such as `.[!.]* ..?* *` to match the files directly (e.g., in a for loop). Another option that may provide both readability and portability is repeating the match, once for hidden file and once for non-hidden files.

The second task is accomplished by resorting to the package management functions available at `src/package.sh`. The `package_manager` function abstracts the actualy package manager provided by the underlying system and provides an OS-independent way to query the current manually installed packages.

Through the parsed `packages` configuration file at the root of the configuration directory (`~/.config/tori/packages` by default), both package lists are sorted and deduplicated before they can be filtered by each other using `grep` inverted matching.

This allows us to obtain both differences and display them to the user. If no resolution strategy has been configured, several options are displayed:

1. Install/uninstall all
2. Enter packages to install/uninstall 
3. Add all to/remove all from configuration
4. Enter packages to add to/remove from configuration
5. Decide in editor

Not all of these options are implemented and some require significant more effort than others. The last option, in particular, requires defining and parsing a syntax that allows users to interface with the possible options.
