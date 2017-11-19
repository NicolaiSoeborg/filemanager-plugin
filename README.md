# Filemanager Plugin

A simple plugin that allows for easy navigation of a file tree.

To install, simply run `plugin install filemanager` and restart Micro.

Now it will be possible to open a navigation panel by running 
the command `tree` (<kbd>Ctrl</kbd> + <kbd>E</kbd>) or creating
a keybinding like so:
```
{
	"CtrlW":  "filemanager.ToggleTree"
}
```

## Example

![filemanager](https://i.imgur.com/MBou7Hb.png "Filemanager")

## Issues

Please use the issue tracker to fill issues or feature requests!


### Known Issues

* Version 2 not backwards compatible, only works on Micro Editor version 1.3.2 and above.