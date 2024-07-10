tori looks for configuration in `~/.config/tori`.

In this directory, you can create the following files and directories:

- `tori.conf`: configures options that will determine how tori itself behaves
- `packages`: a list of packages containing one package name per line
  - blank lines and lines beginning with a `#` are ignored
- `base`: a directory containing any number of files you can tell tori to copy to specific locations

## Configuration options

The `tori.conf` file must use the following format:

```conf
tori_root = ~/.local/apps/my-tori-installation
```

The following configuration options can be used to specify how you want tori to behave:

- `tori_root`


Configuration options are case insensitive. The spaces around the `=` character are optional. Blank lines and lines beginning with a `#` are ignored. 

You can use `~` and `$HOME` to represent your home directory. `$HOME` will be replaced in every occasion with your home directory, while `~` will only be replaced for the first occasion it appears in the configuration value.

Configuration values must _not_ contain the character `*`.

## Package lists

tori will read the `packages` file and check if it matches the currently installed packages. If it does not match, it will ask you how to proceed.

If you would prefer not to be asked how to proceed, you can configure a default action to be taken for package lists conflict resolution.

The application only concerns itself with manually installed packages. Any dependencies pulled automatically should not be added to the removal list. This is done by querying your package manager specifically for a list of manually installed packages.

## Base files

tori will go through the contents of the `base` directory and take different actions depending on how they are laid out.

If you have top-level directories inside `base` that match the directories starting from your system's root (for example, a `base/etc` directory), tori will recursively inspect this directory for files and compare them to the contents of the matching directories in the system.

If any of the files differ from their counterparts on the actual system, tori will ask you how to proceed. If you do not want to be asked every time, you can configure tori to take a specific action without asking.

If you decide to do so, bear in mind important files may get overwritten without warning. tori will create backups in the `bkp` directory every time a file is modified or overwritten.

If you would rather not replicate the system directory hierarchy in your `base`directory, you can also place the files inside `base` itself or in any other structure you desire.

In this case, you will have to manually specify if you want these files to be matched against any system-level files, and, if so, where those files are.
