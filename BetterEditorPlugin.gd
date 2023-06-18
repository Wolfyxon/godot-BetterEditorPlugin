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

var fs_context_menu:PopupMenu

## Returns an Array of [PopupMenu]s containing context (right click) menus in the FileSystem dock
func get_fs_context_menus() -> Array:
	var dock:FileSystemDock = get_editor_interface().get_file_system_dock()
	return get_children_by_class_name(dock,"PopupMenu")

## Returns the current context (right click) menu in the FileSystem dock.
func get_fs_context_menu() -> PopupMenu:
	if fs_context_menu: return fs_context_menu
	var menus = get_fs_context_menus()
	if menus.size()==0: return
	var menu = menus[menus.size()-1]
	fs_context_menu = menu
	return menu

func get_fs_tree() -> Tree:
	return get_first_descendant_by_class_name(get_editor_interface().get_file_system_dock(),"Tree",true)
	
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

## A recursive function that returns all nodes in tree of selected node.
static func get_descendants(node:Node,include_internal:=true) -> Array[Node]:
	var res:Array[Node] = []
	
	for i in node.get_children(include_internal):
		if i.get_child_count(include_internal) != 0: res.append_array(get_descendants(i,include_internal))
		res.append(i)
	
	return res

static func get_values_by_type(array:Array, type:int) -> Array:
	var res = []
	for i in array:
		if type == typeof(i): res.append(i)
	return res

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
	

static func get_children_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Array:
	return get_objects_by_class_name(node.get_children(include_internal),class_name_,strcit)
	
static func get_descendants_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Array:
	return get_objects_by_class_name(get_descendants(node,include_internal),class_name_,strcit)
	
static func get_first_child_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Node:
	return get_first_object_by_class_name(node.get_children(include_internal),class_name_,strcit)
	
static func get_first_descendant_by_class_name(node:Node, class_name_:String, strcit:=false,include_internal:=true) -> Node:
	return get_first_object_by_class_name(get_descendants(node,include_internal),class_name_,strcit)
	
	
	
	
