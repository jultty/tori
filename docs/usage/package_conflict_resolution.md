When running `tori check`, tori will generate two package lists: one with your installed packages and one from the `packages` file in your configuration directory.

In case it finds differences between the two lists, its default behavior is to ask you what to do. This approach is described in the following section.

You can also configure tori to automatically choose a given strategy in case you would prefer not to answer every time or if you are setting up an automated workflow. For details on this approach, see the section on **Non-Interactive Configuration**.

## Interactive Resolution

If it finds a difference between the two package lists, it will present you with a list of packages and a menu with several conflict resolution strategies.

tori will perform two separate checks that may produce two separate dialogues like the one described above. It checks for packages found in the configuration that are missing from the system and for packages found in the system but missing from the configuration.

If it finds packages in your configuration that are not installed on the system, it will present you with the following choices:

- `Install all`: The exact list of packages just displayed is passed to the package manager's install option. The package manager may ask for additional confirmation.

If it finds packages installed on the system but not listed in your configuration, it will present you with the following choices:

- `Uninstall all`: The exact list of packages just displayed is passed to the package manager's uninstall option. The package manager may ask for additional confirmation.
- `Cancel`: Do nothing and close the dialog

## Non-Interactive Resolution

Non-Interactive Resolution is not yet implemented.
