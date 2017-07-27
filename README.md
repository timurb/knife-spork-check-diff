# Knife spork check diff plugin

This is a plugin for [knife-spork](https://github.com/jonlives/knife-spork).
It hooks into `knife spork promote` command, checks if the local environment file differs from remote and produces warning if they differ.

## Installation

1. `chef gem install -N hashdiff`
2. Copy `check_diff.rb` to your `custom_plugin_path` defined in spork config.

Then update your `spork-config.yml`:
```
plugins:
  checkdiff:
    epic_fail: true
```

Plugin parameters:
* `epic_fail`: if set to true the promote command is aborted if local enviroment is different from remote one. Otherwise only a warning is produced.

## License and authors
Plugin is mostly based on knife-spork codebase by Jon Cowie and contributors.

* Author:: Timur Batyrshin <erthad@gmail.com>
* Author:: Jon Cowie <jonlives@gmail.com>
* License:: GPL
