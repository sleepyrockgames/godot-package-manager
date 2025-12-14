@tool
class_name GodotPackageManager extends EditorPlugin

var ui_interface:Resource = load("res://addons/godot-package-manager/interfaces/package_manager_interface.tscn")
var manager_window:GPM_PackageManagerWindow

const IS_DEBUG:bool = true
const DIRECTORY_SEPARATOR:String = "/"

const PM_PROJECT_CONFIG_DIR:String = "res://.godot/editor/godot_package_manager"
const PM_PROJECT_CONFIG_PATH:String = PM_PROJECT_CONFIG_DIR + DIRECTORY_SEPARATOR + "godot_package_manager.cfg"

static var loaded_config:GPM_PackageManagerConfig

func _enter_tree() -> void:
	add_tool_menu_item("Open Package Manager", open_plugin_interface)

	var config_loaded:bool = try_load_config()

	if(!config_loaded):
		loaded_config = GPM_PackageManagerConfig.new()
		# TODO(@sleepyrockgames): Show warning and popup settings dialog
		printerr("Warning: An error occured loading the package manager settings! Please validate all settings are correct!")
	else:
		print("Loaded package manager settings!")
		print(loaded_config.to_json())
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
	
	manager_window.popup_centered()

	pass


func try_load_config()->bool:
	if(!DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(PM_PROJECT_CONFIG_DIR))):
		printerr("Failed to load package manager settings: project settings directory doesn't exist!")
		return false
	if(!FileAccess.file_exists(ProjectSettings.globalize_path(PM_PROJECT_CONFIG_PATH))):
		printerr("Failed to load package manager settings: project config file doesn't exist")
		return false
		
	var user_config_file_location:String

	var base_config_file:FileAccess = FileAccess.open(GodotPackageManager.PM_PROJECT_CONFIG_PATH, FileAccess.READ)
	if(base_config_file == null):
		printerr("Failed to read PROJECT config file: " + error_string(FileAccess.get_open_error()))
		return false
		
	user_config_file_location = base_config_file.get_line()
	base_config_file.close()

	var user_config_file:FileAccess = FileAccess.open(user_config_file_location, FileAccess.READ)
	if(user_config_file == null):
		printerr("Failed to read USER config file: " + error_string(FileAccess.get_open_error()))
		return false
	
	var config_data:String = user_config_file.get_as_text()
	user_config_file.close()

	var parsed_config:GPM_PackageManagerConfig = GPM_PackageManagerConfig.from_json(config_data)
	if(!parsed_config.validate_config()):
		printerr("Malformed package manager config was loaded!")
		return false

	GodotPackageManager.loaded_config = parsed_config
	return true
	pass

## Attempts to write the provided settings to the config
static func write_settings_to_config(new_config:GPM_PackageManagerConfig)->String:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GodotPackageManager.PM_PROJECT_CONFIG_DIR))

	# Write the base lookup
	var base_config_file:FileAccess = FileAccess.open(GodotPackageManager.PM_PROJECT_CONFIG_PATH, FileAccess.WRITE)
	if(base_config_file == null):
		return "Failed to write PROJECT config file: " + error_string(FileAccess.get_open_error())
		pass
	else:
		base_config_file.store_string(new_config.config_file_location)
		base_config_file.close()


	var file:FileAccess = FileAccess.open(new_config.config_file_location, FileAccess.WRITE)
	# Failed to open
	if(file == null):
		return "Failed to write config file: " + error_string(FileAccess.get_open_error())
		pass
	else:
		file.store_string(new_config.to_json())
		file.close()
		GodotPackageManager.loaded_config = new_config # Update the main config

	return ""
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
