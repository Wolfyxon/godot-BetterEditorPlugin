# This example plugin is a part of https://github.com/Wolfyxon/godot-BetterEditorPlugin/
# and it requires the BetterEditorPlugin.gd file to be in the project. 

@tool
extends BetterEditorPlugin

var id = "open_in_terminal"

func _enter_tree():
	register_fs_dir_context_option("Open in terminal",id,load(get_script().get_path().get_base_dir()+"/icon.svg"))
	filesystem_context_menu_item_clicked.connect(_clicked)

func _clicked(item):
	if item.get_string_id() != id: return
	var dir = ProjectSettings.globalize_path(get_fs_selected_path())
	match OS.get_name():
		"Linux": OS.create_process("exo-open",["--working-directory", dir, "--launch" ,"TerminalEmulator"])
		"Windows": OS.create_process("cmd",["/K","cd "+dir])
		
		_: push_error("Sorry your OS is not supported. Please open a issue or a pull request")
