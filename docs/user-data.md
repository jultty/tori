User data is initially configured to $HOME/.config/tori. At this stage, this allows concentrating all necessary data in a single place, however it is not ideal to have non-configuration file there.

When making these configurable, it would be interesting to move the default backup location to $HOME/.local.

The user data is organized in two main directories: `base` and `bkp`.

- `base`: contains the files that will be matched against the current system's files
- `bkp`: contains the original files prior to any intervention by `tori`. This directory is further split into two directories:
  - `canonical`: contains the very first version found for this file prior to any intervention by `tori`. If `tori` is running for the first time on a brand new system, this directory should contain the original files shipped by the operating system.
  - `ephemeral`: contains date-stamped versions of files prior to each occasion in which `tori` had to modify, delete or move them. This directory is not essential to the functioning of `tori`. It is provided as a safety net for the user and may be deleted at any time. It will be automatically recreated.

Both of these directories mimic the file structure found from the root of the file system. For example, this is how one such structure could look like:

```
/home/user/.config/tori
├── base
│   └── home
│       └── user
            ├── .profile
│           └── .shrc
└── bkp
    └── canonical
        └── home
            └── user
                ├── .profile
                └── .shrc
```

`tori` will look only for regular files inside your configuration directory and currently will ignore symbolic link and any other filetype when scanning it.
