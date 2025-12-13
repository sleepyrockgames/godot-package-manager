@tool
class_name GPM_PackageManagerConfigUI extends Window

@onready var config_file_location_text:LineEdit = %ConfigLocation
@onready var config_file_browser_button:Button = %OpenConfigLocationButton
@onready var save_config_button:Button = %SaveConfigButton

var config:GPM_PackageManagerConfig = GPM_PackageManagerConfig.new()

func _ready() -> void:
    close_requested.connect(hide)
    config_file_browser_button.pressed.connect(open_config_file_browser)
    save_config_button.pressed.connect(write_settings_to_config)
    pass

func on_config_path_set(new_path:String, is_directory:bool)->void:
    if(is_directory):
        new_path += GodotPackageManager.DIRECTORY_SEPARATOR + "godot_package_manager.config"
    config_file_location_text.text = new_path
    config.config_file_location = new_path
    pass

## Opens a file dialog to locate the config file location
func open_config_file_browser()->void:
    var new_file_dialog:FileDialog = FileDialog.new()
    add_child(new_file_dialog)

    new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
    new_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    new_file_dialog.filters = ["*.config"]
    new_file_dialog.dir_selected.connect(on_config_path_set.bind(true))
    new_file_dialog.file_selected.connect(on_config_path_set.bind(false))
    new_file_dialog.popup_centered()
    new_file_dialog.close_requested.connect(func(): new_file_dialog.free())
    pass

func write_settings_to_config()->void:
    # TODO(@sleepyrockgames): Implement me
    printerr("Config save not currently implemented!")
    print(config.to_json())
    pass