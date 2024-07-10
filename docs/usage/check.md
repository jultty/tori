When you run `tori check`, tori will look into your configuration files and perform two tasks:

- Compare the files inside the `base` directory to the actual matching files on the system
- Compare the package list in the `packages` file to the manually installed packages

If any divergence is found, it will prompt you on what action to take.
