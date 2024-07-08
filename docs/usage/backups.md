tori creates a backup directory called `bkp` that contains two top-level directories:

- `canonical`: Canonical backups are created the first time tori is told to modify a given file. If there is already a canonical backup, it defers to the cretaion of an ephemeral one. If tori is running against a recently-instaled system, the canonical backups should be close to the original state of the system as of its installation.
- `ephemeral`: Ephemeral backups are timestamped backups created every time tori has to modify a file. This is mainly meant as a safety net against undesired consequences when using non-interactive options.
