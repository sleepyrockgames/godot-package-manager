@tool
class_name GPM_PackageManagerConfigUI extends Window

var source_ui_prefab:PackedScene = load("res://addons/godot-package-manager/interfaces/config_source_location_ui.tscn")

@onready var config_file_location_text:LineEdit = %ConfigLocation
@onready var config_file_browser_button:Button = %OpenConfigLocationButton
@onready var save_config_button:Button = %SaveConfigButton
@export var add_new_source_button:Button
@export var source_list_container:VBoxContainer

## The map of source paths to the corresponding list widget
var source_ui_list:Dictionary = {}

## The config being modified
var config:GPM_PackageManagerConfig = GPM_PackageManagerConfig.new()

func _ready() -> void:
    config = GodotPackageManager.loaded_config.deep_copy()

    close_requested.connect(hide)
    config_file_browser_button.pressed.connect(open_config_file_browser)
    save_config_button.pressed.connect(_on_save_pressed)
    add_new_source_button.pressed.connect(open_package_source_file_browser)
    config_file_location_text.text = config.config_file_location
    update_source_list_ui()
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
    if(config.config_file_location != ""):
        new_file_dialog.current_dir = config.config_file_location
    new_file_dialog.filters = ["*.config"]
    new_file_dialog.dir_selected.connect(on_config_path_set.bind(true))
    new_file_dialog.file_selected.connect(on_config_path_set.bind(false))
    new_file_dialog.popup_centered()
    new_file_dialog.close_requested.connect(func(): new_file_dialog.free())
    pass

## Updates the source list UI
func update_source_list_ui()->void:
    var sources_to_remove:Array = source_ui_list.keys().filter(func(elem)->bool: return !config.package_source_locations.has(elem))

    # Remove any deleted sources from the list
    for source:String in sources_to_remove:
        (source_ui_list[source] as Control).queue_free()
        source_ui_list.erase(source)

    for new_source:String in config.package_source_locations:
        # Already has a UI element
        if(source_ui_list.has(new_source)):
            continue

        var new_prefab:GPM_ConfigSourceUI = source_ui_prefab.instantiate() as GPM_ConfigSourceUI
        source_list_container.add_child(new_prefab)
        new_prefab.label_node.text = new_source
        source_ui_list[new_source] = new_prefab
        new_prefab.remove_requested.connect(_on_source_deleted.bind(new_source))
        pass

    pass

## Callback for when a source is requested to be removed
func _on_source_deleted(path:String)->void:
    config.package_source_locations.erase(path)
    update_source_list_ui()
    pass

func on_add_new_source_submitted(path:String)->void:
    if(config.package_source_locations.has(path)):
        # TODO(@sleepyrockgames): Add warning dialog to say it already exists
        open_config_file_browser()
        return
    
    config.package_source_locations.append(path)
    update_source_list_ui()
    pass

func _on_save_pressed()->void:
    var result = GodotPackageManager.write_settings_to_config(config)
    if(result == ""):
        result = "Changes saved successfully!"

    var confirm_dialog:AcceptDialog = AcceptDialog.new()
    confirm_dialog.dialog_text = result
    confirm_dialog.ok_button_text = "Close"
    add_child(confirm_dialog)
    confirm_dialog.close_requested.connect(func():confirm_dialog.queue_free())
    confirm_dialog.popup_centered()
    pass

## Opens a directory browser to locate package sources
func open_package_source_file_browser()->void:
    var new_file_dialog:FileDialog = FileDialog.new()
    add_child(new_file_dialog)

    new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    new_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    
    new_file_dialog.dir_selected.connect(on_add_new_source_submitted, CONNECT_ONE_SHOT)

    new_file_dialog.popup_centered()
    new_file_dialog.close_requested.connect(func(): new_file_dialog.free())
    