# Alticns

Alticns is a command line tool to manage alternative icons for Mac apps easily.

## Features

- Change Mac app icons with one command
- Store `.icns` files

## Install

You can install alticns from Homebrew.

```shell
$ brew tap Fus1onDev/homebrew-tap
$ brew install alticns
```

## Usage

### `set`

Apply the alternate icon and store the image file in the `.alticns` directory.

```shell
$ alticns set /Applications/Firefox.app Downloads/new-icon.icns
```

It uses the path of the target `.app` file and the path of the `.icns` file as arguments.

With the `--remove` (`-r`) flag, the original file is removed at the same time.

To use stored icons, you must add `--stored` (`-s`) flag.

```shell
$ alticns set -s /Applications/Firefox.app
```

Also, `--all` (`-a`) flag instead of the arguments will apply all saved icons to the apps.

```shell
$ alticns set -a
```

### `reset`

Restore the app icon to the original one.

```shell
$ alticns reset /Applications/Firefox.app
```

The `--all` (`-a`) flag will do this for all apps, and the `--remove` (`-r`) flag will remove stored icons.

```shell
$ alticns reset -ar
```

### `list`

Shows a tree of stored icons.

It may contain icons that have been saved but not applied.

```shell
$ alticns list
Applications
  Firefox
  Microsoft Excel
  Microsoft PowerPoint
  Microsoft Outlook
  Microsoft Word
  AppCleaner
  Microsoft OneNote
```

## License

MIT