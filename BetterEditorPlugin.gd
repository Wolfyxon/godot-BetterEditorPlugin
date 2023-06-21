## A class for making editor plugins with more options than regular [EditorPlugin] and also.
## some additional utilities.
## [codeblock]
## @tool
## extends BetterEditorPlugin 
## func _enter_tree():
##     # Code executed when the plugin gets enabled
##     pass
## func _exit_tree():
##     # Code executed when the plugin gets disabled
##     pass
## [/codeblock] [br]
## Have fun!

@tool
extends EditorPlugin
class_name BetterEditorPlugin

signal filesystem_context_menu_opened
signal filesystem_context_menu_closed
signal filesystem_dir_context_menu_opened
signal filesystem_file_context_menu_opened
signal filesystem_context_menu_item_clicked(item:PopupMenuItem)
signal filesystem_context_menu_index_clicked(index:int)
signal filesystem_context_menu_id_clicked(id:int)

enum PATH_TYPE {Nonexistent, File, Directory}

var fs_context_menu:PopupMenu

var registered_fs_dir_options = [
#	{
#		label: "option label"
#		icon: Texture2D or null
#	}
]
var registered_fs_file_options = [
#	{
#		label: "option label"
#		icon: Texture2D or null
#	}
]
## A class for easier dealing with items in [PopupMenu]. 
class PopupMenuItem:
	
	## The source [PopupMenu]
	var popup_menu:PopupMenu
	## Item index
	var index:int

	func _init(source:PopupMenu,index:int):
		popup_menu = source
		self.index = index
	
	## Returns the item ID at the current index
	func get_id() -> int: return popup_menu.get_item_id(index)
	## Returns the item index
	func get_index() -> int: return index
	## Returns the item text
	func get_text() -> String: return popup_menu.get_item_text(index)
	## Returns the item icon texture (if present)
	func get_icon() -> Texture2D: return popup_menu.get_item_icon(index)
	## Returns the item metadata (if present)
	func get_metadata(): return popup_menu.get_item_metadata(index)
	## Returns the item String ID used for identifying the options. Applies only to custom options.
	func get_string_id() -> String:
		var meta = get_metadata()
		if meta==null or !typeof(meta) == TYPE_DICTIONARY: return ""
		return meta["strID"]
	
	## Sets the item text
	func set_text(text:String): popup_menu.set_item_text(index,text)
	## Sets the item icon texture
	func set_icon(icon:Texture2D): popup_menu.set_item_icon(index,icon)
	## Sets item metadata. WARNING: this might remove the String ID
	func set_metadata(meta): popup_menu.set_item_metadata(index,meta)
	## Sets the item ID. Proceed with caution as this often causes issues
	func set_id(id:int): popup_menu.set_item_id(index, id)
	## Sets if the item is disabled or not
	func set_disabled(disabled:bool): popup_menu.set_item_disabled(index,disabled)
	## Disables the item
	func disable(): set_disabled(true)
	## Enables the item
	func enable(): set_disabled(false)
	
# ============== Private methods ============== #
# Please do not overwrite these methods or this class won't work properly

# _enter_tree and _exit_tree can't be used because they will be overwritten by the extended classes.
# _notification will always fire no matter if it's overwritten. 
func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		get_fs_context_menu()
		fs_context_menu.about_to_popup.connect(_fs_context_menu_opened)
		fs_context_menu.popup_hide.connect(_fs_context_menu_closed)
		fs_context_menu.index_pressed.connect(_fs_context_menu_index_clicked)
		fs_context_menu.id_pressed.connect(_fs_context_menu_id_clicked)
		
	
	if what == NOTIFICATION_EXIT_TREE:
		pass

func _get_id_for_new_fs_context_item() -> int:
	return get_fs_context_menu().item_count+1

func _fs_context_menu_opened():
	filesystem_context_menu_opened.emit()


	if is_fs_selected_path_file_or_dir() == PATH_TYPE.Directory:
		filesystem_dir_context_menu_opened.emit()
		for i in registered_fs_dir_options:
			var label = i["label"]
			if ("icon" in i) and i["icon"]:
				add_fs_context_menu_icon_item(i["label"],i["icon"],{"strID":i["strID"]})
			else:
				add_fs_context_menu_item(i["label"],{"strID":i["strID"]})
		
	if is_fs_selected_path_file_or_dir() == PATH_TYPE.File:
		filesystem_file_context_menu_opened.emit()
		for i in registered_fs_file_options:
			var label = i["label"]
			if ("icon" in i) and i["icon"]:
				add_fs_context_menu_icon_item(i["label"],i["icon"],{"strID":i["strID"]})
			else:
				add_fs_context_menu_item(i["label"],{"strID":i["strID"]})

func _fs_context_menu_closed():
	filesystem_context_menu_closed.emit()

func _fs_context_menu_index_clicked(index:int):
	filesystem_context_menu_index_clicked.emit(index)
	var item = PopupMenuItem.new(get_fs_context_menu(),index)
	if item: filesystem_context_menu_item_clicked.emit(item)

func _fs_context_menu_id_clicked(id:int):
	filesystem_context_menu_id_clicked.emit(id)

# ============== User methods ============== #

## Returns the current context (right click) menu in the FileSystem dock.
func get_fs_context_menu() -> PopupMenu:
	if fs_context_menu: return fs_context_menu
	var dock:FileSystemDock = get_editor_interface().get_file_system_dock()
	var menus = get_children_by_class_name(dock,"PopupMenu")
	if menus.size()==0: return
	var menu = menus[menus.size()-1]
	fs_context_menu = menu
	return menu

## Permanentaly (unless the plugin is disabled) adds an option to the directory context (right click) menu in the FileSystem dock
func register_fs_dir_context_option(label:String, id:String="", icon:Texture2D=null):
	if id == "": id = label
	registered_fs_dir_options.append(
		{
			"label": label,
			"icon": icon,
			"strID": id
		}
	)

## Permanentaly (unless the plugin is disabled) adds an option to the file context (right click) menu in the FileSystem dock
func register_fs_file_context_option(label:String, id:String="", icon:Texture2D=null):
	if id == "": id = label
	registered_fs_file_options.append(
		{
			"label": label,
			"icon": icon,
			"strID": id
		}
	)

## Adds a button to the FileSystem dock context (right click) menu. Returns index of the created item
func add_fs_context_menu_item(label:String,meta=null) -> int:
	var id = _get_id_for_new_fs_context_item()
	get_fs_context_menu().add_item(label,id)
	var idx = id-1#get_fs_context_menu().get_item_index(id)
	get_fs_context_menu().set_item_metadata(idx,meta)
	return idx

## Adds a button with an icon to the FileSystem dock context (right click) menu. Returns index of the created item
func add_fs_context_menu_icon_item(label:String, icon:Texture2D, meta=null) -> int:
	var id = _get_id_for_new_fs_context_item()
	get_fs_context_menu().add_icon_item(icon,label,id)
	var idx = id-1#get_fs_context_menu().get_item_index(id)
	get_fs_context_menu().set_item_metadata(idx,meta)
	return idx

## Adds a check button to the FileSystem dock context (right click) menu. Returns index of the created item
func add_fs_context_menu_check_item(label:String, meta=null) -> int:
	var id = _get_id_for_new_fs_context_item()
	get_fs_context_menu().add_check_item(label,id)
	var idx = id-1#get_fs_context_menu().get_item_index(id)
	get_fs_context_menu().set_item_metadata(idx,meta)
	return idx

## Adds a check button with an icon to the FileSystem dock context (right click) menu
func add_fs_context_menu_icon_check_item(label:String, icon:Texture2D):
	get_fs_context_menu().add_icon_check_item(icon, label, _get_id_for_new_fs_context_item())

## Gets the file tree in the FileSystem dock.
func get_fs_tree() -> Tree:
	return get_first_descendant_by_class_name(get_editor_interface().get_file_system_dock(),"Tree",true)

## Gets the currently selected [TreeItem] in the FileSystem dock
func get_fs_selected_item() -> TreeItem:
	return get_fs_tree().get_selected()
	
## Returns selected [TreeItem]s in the FileSystem dock
func get_fs_selected_items() -> Array[TreeItem]: 
	return get_selected_tree_items(get_fs_tree())

## Returns the name of the currently selected file or directory in the FileSystem dock
func get_fs_selected_item_name() -> String:
	var item:TreeItem = get_fs_selected_item()
	if !item: return ""
	return item.get_text(0)
	
## Returns all names of the currently selected files and directories in the FileSystem dock.
func get_fs_selected_names() -> Array[String]:
	var res:Array[String] = []
	for i in get_fs_selected_items():
		res.append(i.get_text(0))
	return res

## Returns the path to the currently selected file or directory in the FileSystem dock.
func get_fs_selected_path() -> String:
	var item = get_fs_selected_item()
	if !item: return ""
	return item.get_metadata(0)

## Returns paths to all selected files and directories in the FileSystem dock
func get_fs_selected_paths() -> Array[String]:
	var res:Array[String] = []
	for i in get_fs_selected_items():
		res.append(i.get_metadata(0))
	return res

## Checks if the selected entry in the FileSystem dock is a file or directory. See also [method is_file_or_dir]
func is_fs_selected_path_file_or_dir() -> PATH_TYPE:
	var path = get_fs_selected_path()
	if path == "": return PATH_TYPE.Nonexistent
	return is_file_or_dir(path)

# ============== Static methods ============== #

## Returns a String type name of a TYPE enum. Example [code]print( type_name( typeof("hello") ) )[/code] will print [code]String[/code]
static func type_name(type:int) -> String:
	match type:
		TYPE_AABB: return "AABB"
		TYPE_ARRAY: return "Array"
		TYPE_BASIS: return "Basis"
		TYPE_BOOL: return "Bool"
		TYPE_CALLABLE: return "Callable"
		TYPE_COLOR: return "Color"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_FLOAT: return "float"
		TYPE_INT: return "int"
		TYPE_MAX: return "max"
		TYPE_NIL: return "null"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_OBJECT: return "Object"
		TYPE_PLANE: return "Plane"
		TYPE_PROJECTION: return "Projection"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_RID: return "RID"
		TYPE_SIGNAL: return "Signal"
		TYPE_STRING: return "String"
		TYPE_STRING_NAME: return "StringName"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_VECTOR4: return "Vector4"
		TYPE_VECTOR4I: return "Vector4i"
		# Arrays
		TYPE_PACKED_BYTE_ARRAY: return "Array[byte]"
		TYPE_PACKED_COLOR_ARRAY: return "Array[Color]"
		TYPE_PACKED_FLOAT32_ARRAY: return "Array[float32]"
		TYPE_PACKED_FLOAT64_ARRAY: return "Array[float64]"
		TYPE_PACKED_INT32_ARRAY: return "Array[int32]"
		TYPE_PACKED_INT64_ARRAY: return "Array[int64]"
		TYPE_PACKED_STRING_ARRAY: return "Array[String]"
		TYPE_PACKED_VECTOR2_ARRAY: return "Array[Vector2]"
		TYPE_PACKED_VECTOR3_ARRAY: return "Array[Vector3]"

	return "Unknown"

## Returns a String type name of a value. Example [code]print( string_typeof("hello") )[/code] will print [code]String[/code]
static func string_typeof(value) -> String: return type_name(typeof(value))

## Returns all selected [TreeItem]s in a [Tree]
static func get_selected_tree_items(tree:Tree) -> Array[TreeItem]:
	var res:Array[TreeItem] = []
	var first = tree.get_selected()
	var next = tree.get_next_selected(null)
	
	while next:
		res.append(next)
		next = tree.get_next_selected(next)
	
	return res

## A recursive function that returns all nodes in tree of selected node.
static func get_descendants(node:Node,include_internal:=true) -> Array[Node]:
	var res:Array[Node] = []
	
	for i in node.get_children(include_internal):
		if i.get_child_count(include_internal) != 0: res.append_array(get_descendants(i,include_internal))
		res.append(i)
	
	return res

## Returns all values from given array matching the specified type.
static func get_values_by_type(array:Array, type:int) -> Array:
	var res = []
	for i in array:
		if type == typeof(i): res.append(i)
	return res

## Returns all [Object]s and classes extending them such as [Node]s from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_objects_by_class_name(array:Array, class_name_:String, strict:=false) -> Array:
	var res = []
	for i in array:
		if i is Object:
			if strict: 
				if i.get_class() == class_name_: res.append(i)
			else:
				if i.is_class(class_name_): res.append(i)
		else:
			push_error(str(i)+" is not an Object. It's an "+string_typeof(i)+". Consider using get_values_by_type()")
	return res

## Returns the first [Object] or a class extending it such as [Node] from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_first_object_by_class_name(array:Array, class_name_:String, strict:=false) -> Object:
	for i in array:
		if i is Object:
			if strict: 
				if i.get_class() == class_name_: return i
			else:
				if i.is_class(class_name_): return i
		else:
			push_error(str(i)+" is not an Object. It's an "+string_typeof(i)+". Consider using get_values_by_type()")
	return null
	

## Returns all children [Node]s from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_children_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Array:
	return get_objects_by_class_name(node.get_children(include_internal),class_name_,strcit)
	
## Returns all descendant [Node]s from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_descendants_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Array:
	return get_objects_by_class_name(get_descendants(node,include_internal),class_name_,strcit)
	
## Returns the first child [Node] from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_first_child_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Node:
	return get_first_object_by_class_name(node.get_children(include_internal),class_name_,strcit)
	
## Returns the first descendant [Node] from the given array, matching (if [code]strict[/code] is true) the given class name or extending it (if [code]strict[/code] is false) 
static func get_first_descendant_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Node:
	return get_first_object_by_class_name(get_descendants(node,include_internal),class_name_,strcit)
	
## Checks if a directory exists at the given local or absolute path.
static func dir_exists(path:String) -> bool:
	if path == "res://": return true
	return DirAccess.open(path).dir_exists(path)

## Checks if a file exists at the given local or absolute path.
static func file_exists(path:String) -> bool:
	if path == "res://": return false
	return DirAccess.open(path.get_base_dir()).file_exists(path)

## Checks if a file or directory exists at the given local or absolute path.
static func path_exists(path:String) -> bool:
	return file_exists(path) or dir_exists(path)

## Determines is a file or a directory exists at the given path. Returns [enum PATH_TYPE.Nonexistent] if nothing exists.
static func is_file_or_dir(path:String) -> PATH_TYPE:
	if file_exists(path): return PATH_TYPE.File
	if dir_exists(path): return PATH_TYPE.Directory
	return PATH_TYPE.Nonexistent
