# tori

tori is a tool to track your personal systems' configurations and replicate them.

If you'd like a more detailed description of what it is, its purpose, origins and goals, see the [announcement blog post](https://blog.jutty.dev/posts/introducing-tori.html).

You can find documentation in the [docs](docs) directory:
- [Usage documentation](docs/usage)
- [Development documentation](docs/development)

## Installation

As it is still in very early development, tori is not yet packaged.

If you want to try it, you can clone this repository to your system and create the configuration file at `~/.config/tori/tori.conf` containing the following setting:

```conf
tori_root = /path/to/repository
```

If you clone it to the default location, `~/.local/share/tori`, the above step is not necessary.

Finally, you need to symlink the `tori` file at the repository root to somewhere on your `$PATH`:

```
ln -s /path/to/repository/tori $HOME/.local/bin/tori
```

## Usage

Currently, the following options are implemented:

- `check`: check for divergences between the configuration and the system
- `help`: show a usage summary with supported options
- `version`: print the current version and its release date

To issue a command, use `tori <command>`, as in `tori check`.
