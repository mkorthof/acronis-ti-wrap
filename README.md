# Arcronis True Image 2016 (Home) Wrapper

This script first checks if there's enough free disk space and deletes the oldest ".tib" file if needed. Then it runs True Image with the most recent settings (using ".tis" file).

Where ".tib" is TrueImage Backup and ".tis" is TrueImage Script (XML)

## Configuration

First configure backup settings in True Image GUI which will automatically create a ".tis" file. 

Then edit 'acronis.bat' to set backup size and target drive.

Set minimal needed free space in MB, at least the size of one '.tib' file (Default is "500GB")

`SET /A REQ_FREE=500000`

Change backup drive letter and directory (Default is "F:\AcronisBackup")

`SET "BKP_DRIVE=F"`

`SET "BKP_DIR=AcronisBackup`

## Usage

Run `acronis.bat` as Administrator without arguments to start backup.

To view last log use: `arcronis.bat -l`

## More info

- <https://kb.acronis.com/content/47143>
- <https://forum.acronis.com>
