# Filemanager Plugin

## Basics

The top line always has the current directory's path to show you where you are.
The `..` near the top is used to move back a directory, from your current position.

All directories have a `/` added to the end of it, and are syntax-highlighted as a `special` character.
If the directory is expanded, there will be a `+` to the left of it. If it is collapsed there will be a `-` instead.

**NOTE:** If you change files without using the plugin, it can't know what you did.
 The only fix is to close and open the tree.

### Options

| Option                       | Purpose                                                      | Default |
| :--------------------------- | :----------------------------------------------------------- | :------ |
| `filemanager.showdotfiles`   | Show dotfiles (hidden if false)                              | `true`  |
| `filemanager.showignored`    | Show gitignore'd files (hidden if false)                     | `true`  |
| `filemanager.compressparent` | Collapse the parent dir when left is pressed on a child file | `true`  |
| `filemanager.foldersfirst`   | Sorts folders above any files                                | `true`  |
| `filemanager.openonstart`    | Automatically open the file tree when starting Micro         | `false` |

### Commands and Keybindings

The keybindings below are the equivalent to Micro's defaults, and not actually set by the plugin.
If you've changed any of those keybindings, then that key is used instead.

If you want help on keybindings then run this command in micro editor.
`ctl + e` help keybindings

Any of the operations/commands, bind to the labeled API in the table below.

| Command  | Keybinding(s)   | What it does                                                                                | API for `bindings.json`               |
| :------- | :-------------- | :------------------------------------------------------------------------------------------ | :------------------------------------ |
| `tree`   | -               | Open/close the filemanager                                                                         | `filemanager.toggle_tree`             |
| -        | Tab or MouseLeft| Open a file, or go into the directory. Goes back a dir if on `..`                           | `filemanager.try_open_at_cursor`      |
| -        |      →          | Expand directory in tree listing                                                            | `filemanager.uncompress_at_cursor`    |
| -        |      ←          | Collapse directory listing                                                                  | `filemanager.compress_at_cursor`      |
| -        | Shift ⬆         | Go to the target's parent directory                                                         | `filemanager.goto_parent_dir`         |
| -        | Alt Shift {     | Jump to the previous directory in the view                                                  | `filemanager.goto_next_dir`           |
| -        | Alt Shift }     | Jump to the next directory in the view                                                      | `filemanager.goto_prev_dir`           |
| `rm`     | -               | Prompt to delete the target file/directory your cursor is on                                | `filemanager.prompt_delete_at_cursor` |
| `rename` | -               | Rename the file/directory your cursor is on, using the passed name                          | `filemanager.rename_at_cursor`        |
| `touch`  | -               | Make a new file under/into the file/directory your cursor is on, using the passed name      | `filemanager.new_file`                |
| `mkdir`  | -               | Make a new directory under/into the file/directory your cursor is on, using the passed name | `filemanager.new_dir`                 |

#### Notes

- `rename`, `touch`, and `mkdir` require a name to be passed when calling.
  Example: `rename newnamehere`, `touch filenamehere`, `mkdir dirnamehere`.
  If the passed name already exists in the current dir, it will cancel instead of overwriting (for safety).

- The `Ctrl + w` keybinding is to switch which buffer your cursor is on.
  This isn't specific to the plugin, it's just part of Micro, but many people seem to not know this.
