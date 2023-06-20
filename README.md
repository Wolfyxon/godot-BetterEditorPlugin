# BetterEditorPlugin
A upgraded API for Godot editor plugins made in pure GDScript.  
Supports Godot version 4.0 and above.
### Disclaimer
This class might stop working properly in a Godot update changes the node structure of the editor since it uses methods that are not in the official API by manually finding and modifying nodes. This class is also currently work-in-progress.

## Installation
Clone this repository or download `BetterEditorPlugin.gd` anywhere in your project, you may need to restart Godot but it's rarely required. 
Then if you want to use it, replace in your plugin script `extends EditorPlugin` with `extends BetterEditorPlugin`. This is how the top your plugin script should look like:  
```gdscript
@tool
extends BetterEditorPlugin

# ...
```
## Features
Please note that more features will appear over time.  
- manipulating items in the FileSystem dock
- getting selected file and directory paths in the FileSystem dock
- manipulating (includes custom options) context menu in the FileSystem dock
- Many useful static utility functions that might also be helpful outisde plugins

Feel free to suggest anything you'd like to see!

## Examples
- [OpenInTerminal](https://github.com/Wolfyxon/godot-BetterEditorPlugin/tree/main/examples/OpenInTerminal) a example plugin that adds a FileSystem context mneu option that allows you to open the system terminal in the selected directory

## Usage and documentation
All methods are explained. In the script editor on the top right corner press **Search Help**, find `BetterEditorPlugin` then click on it and you will see the full documentation of this class.
