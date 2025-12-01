@tool
extends EditorPlugin

var ui_interface:Resource = load("res://addons/godot-package-manager/interfaces/package_manager_interface.tscn")
var manager_window:GPM_PackageManagerWindow

const IS_DEBUG:bool = true

func _enter_tree() -> void:
	add_tool_menu_item("Open Package Manager", open_plugin_interface)
	pass


## Opens the plugin interface
func open_plugin_interface()->void:

	# "Hot reload" the window if we're in debug
	if(manager_window != null && IS_DEBUG):
		manager_window.get_parent().remove_child(manager_window)
		manager_window.free()
		manager_window = null

	if(manager_window == null):
		manager_window = ui_interface.instantiate()
		EditorInterface.get_editor_main_screen().add_child(manager_window)
	
	manager_window.show()

	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
