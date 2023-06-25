# BetterEditorPlugin
A upgraded API for Godot editor plugins made in pure GDScript.  
Supports Godot version 4.0 and above.

Make sure to read the [wiki](https://github.com/Wolfyxon/godot-BetterEditorPlugin/wiki)
## Installation
Clone this repository or download `BetterEditorPlugin.gd` anywhere in your project, you may need to restart Godot but it's rarely required. 
Then if you want to use it, replace in your plugin script `extends EditorPlugin` with `extends BetterEditorPlugin`. This is how the top your plugin script should look like:  
```gdscript
@tool
extends BetterEditorPlugin

# ...
```
### Plugin makers, please read!
If you are sharing your plugin made with this class, please avoid shipping this class inside the plugin folder or this will cause problems when there's multiple plugins containing it, consider prompting users to download it separately.  
If you still want to ship it inside your plugin, rename this class to example: `BetterEditorPluginForMyCoolPluginName`. Class name is next to the `class_name` statement in the **BetterEditorPlugin.gd** file.

## Features
Please note that more features will appear over time.  
- manipulating items in the FileSystem dock
- getting selected file and directory paths in the FileSystem dock
- Custom context menu options for FileSystem dock and Node Tree
- Many useful static utility functions that might also be helpful outisde plugins

Feel free to suggest anything you'd like to see!

## Examples
- [OpenInTerminal](https://github.com/Wolfyxon/godot-BetterEditorPlugin/tree/main/examples/OpenInTerminal) a example plugin that adds a FileSystem context menu option that allows you to open the system terminal in the selected directory

## Usage and documentation
All methods are explained. In the script editor on the top right corner press **Search Help**, find `BetterEditorPlugin` then click on it and you will see the full documentation of this class.

## Disclaimer
This class might stop working properly if a Godot update changes the node structure of the editor since it uses methods that are not in the official API by manually finding and modifying nodes. This class is also currently work-in-progress.

## TODO
We are planning or currently working on adding these features:
- Full property change detection
- Getting current script text editor
- File change detection

