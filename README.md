# Acronis True Image (Home) Wrapper

For use with Single version Backup Scheme

This script first checks if there's enough free disk space and deletes the oldest ".tib" file if needed. Then it runs TrueImage with the most recent settings (using ".tis" file).

*Where ".tib" is TrueImage Backup and ".tis" is TrueImage Script (XML)*

## Why❔

Reasoning behind this is that I backup (full) to offline external hd which is only powered on during backup. After backup finishes the PC hibernates using the post-script option in TrueImage with `shutdown /h`. I wanted something to trigger backup instead of TI GUI or it's scheduler, and made this wrapper script.

However, now TI kept filling up the drive, which is why there's an option to delete oldest image.

If you (want to) do the same, this scripter be usefull :)

## Configuration

First configure backup settings in TrueImage GUI which will automatically create a ".tis" file.

Specify target drive/dir and free space in MB as options on CLI:

```
acronis.bat -d F:\AcronisBackup -f 500000
```

Or, edit `acronis.bat` to change required free space (default is 500GB)

`SET /A REQ_FREE=500000`

And set backup drive letter and directory (default is "F:\AcronisBackup")

`SET "BKP_DRIVE=F"`

`SET "BKP_DIR=AcronisBackup`

⚠ *Set minimal needed free space to at least the size of one '.tib' file*

## Usage

Run `acronis.bat` as Administrator without arguments to start backup. This will both remove oldest TIB and run TrueImage backup.

The **`-s`** option does not delete and run anything, it displays free space and .tib file size and TI details.

To only remove oldest TIB and not run backup, use **`-o`** option. Could be used as pre-script in TI (untested).

## Help

`C:\❯ acronis.bat  -h`

``` batch
Acronis True Image Wrapper

USAGE: acronis.bat [-h|-d|-f|-l|-n|-s]

       -h   help
       -d   backup drive and path
       -f   free space in MB on drive
       -l   view last log file
       -n   do not start 'after' user command
       -o   remove oldest TIB if needed and exit
       -s   show backup drive and disk space

EXAMPLE: acronis.bat -d F:\AcronisBackup -f 500000

No arguments removes oldest tib and starts TI Backup (needs Admin).
See inside script for default config and details.
```

## More info

- <https://kb.acronis.com/content/47143>
- <https://forum.acronis.com>
