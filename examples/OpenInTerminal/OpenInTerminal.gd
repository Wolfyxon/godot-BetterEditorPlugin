# This example plugin is a part of https://github.com/Wolfyxon/godot-BetterEditorPlugin/
# and it requires the BetterEditorPlugin.gd file to be in the project. 

@tool
extends BetterEditorPlugin # Use BetterEditorPlugin instead of the regular EditorPlugin

var id = "open_in_terminal" # Id of the item you want to use

# Function called when the plugin starts
func _enter_tree():
	# Register the directory option
	register_fs_dir_context_option("Open in terminal",id,load(get_script().get_path().get_base_dir()+"/icon.svg"))
	# Connect the click signal to _clicked
	filesystem_context_menu_item_clicked.connect(_clicked)

# Called when user clicks on a option
func _clicked(item):
	# Stop the function if the ID is not equal to "open_in_terminal"
	if item.get_string_id() != id: return
	# Get the selected path in the FileSystem dock then turn it from a local path into a absolute path
	var dir = ProjectSettings.globalize_path(get_fs_selected_path()) 
	# Check the system name
	match OS.get_name():
		"Linux": 
			# Open the default terminal emulator in the selected directory (might differ on many distributions)
			OS.create_process("exo-open",["--working-directory", dir, "--launch" ,"TerminalEmulator"])
		
		"Windows": 
			# Open cmd at the selected directory
			OS.create_process("cmd",["/K","cd "+dir])
		
		# Show an error if the OS isn't included there
		_: push_error("Sorry your OS is not supported. Please open a issue or a pull request")
