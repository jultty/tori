The `check` executable traverses the configuration directory to assemble a file list containing full paths for both the `base` and `bkp` directories.

This is currently accomplished by resorting to `find`. While this allows for cleaner code, it relies on an external program with an interface that may be unpredictable.

A better option might be using a POSIX-compliant wildcard such as `.[!.]* ..?* *` to match the files directly (e.g., in a for loop).

Another option that may provide both readability and portability is repeating the match, once for hidden file and once for non-hidden files.
