@tool
class_name GPM_NewPackageDialog extends Window

@export var _package_content_display:GPM_PackageFileTreeDisplay
@export var _open_root_path_browser_button:Button

@export var _package_source_dropdown:OptionButton
@export var _create_package_button:Button

# Data
@export var _package_name_input:LineEdit
@export var _package_root_display_label:LineEdit
@export var _package_version_input:LineEdit
@export var _package_description_input:LineEdit

func _ready() -> void:
    close_requested.connect(hide)
    _open_root_path_browser_button.pressed.connect(select_package_root_pressed)
    _create_package_button.pressed.connect(_on_create_button_pressed)


    _package_source_dropdown.clear()

    if(!GodotPackageManager.loaded_config.package_source_locations.is_empty()):
        for source_path:String in GodotPackageManager.loaded_config.package_source_locations:
            _package_source_dropdown.add_item(source_path)
        _package_source_dropdown.select(0)
    else:
        # No sources have been set up- instruct the user and close the dialog
        var dialog:AcceptDialog = GPM_UIOperations.create_warning_dialog(
            "No package sources have been set! Configure one in the settings menu before creating a new package", self)
        dialog.canceled.connect(hide)
        dialog.confirmed.connect(hide)
        dialog.popup_centered()

func _on_root_directory_selected(new_root:String)->void:
    _package_root_display_label.text = new_root
    _package_content_display.build_tree_with_root_path(new_root)
    _package_content_display.set_is_read_only(false)
    pass

func select_package_root_pressed()->void:
    var new_file_dialog:FileDialog = FileDialog.new()
    add_child(new_file_dialog)

    new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    new_file_dialog.access = FileDialog.ACCESS_RESOURCES
    
    new_file_dialog.dir_selected.connect(_on_root_directory_selected, CONNECT_ONE_SHOT)

    new_file_dialog.popup_centered()
    new_file_dialog.close_requested.connect(new_file_dialog.queue_free)
    pass

func _validate_input()->String:
    var package_name:String = _package_name_input.text
    print(package_name)

    if(package_name.is_empty()):
        return "Missing a package name!"

    if(GPM_PackageConfig.INVALID_CHARACTERS.any(func(char): return package_name.contains(char))):
        return "Package name contains invalid characters!"

    var package_desc:String = _package_description_input.text
    if(!package_desc.is_empty() && GPM_PackageConfig.INVALID_CHARACTERS.any(func(char): return package_desc.contains(char))):
        return "Package description contains invalid characters!"

    var version:String = _package_version_input.text
    if(GPM_PackageConfig.INVALID_CHARACTERS.any(func(char): return version.contains(char))):
        return "Package version contains invalid characters!"

    if(_package_root_display_label.text.is_empty()):
        return "No root was defined to select files from!"

    if(_package_content_display.get_all_selected().is_empty()):
        return "No files were selected to add to the package!"

    return ""

func _on_create_button_pressed()->void:
    if(_package_version_input.text.is_empty()):
        _package_version_input.text = "v0.0.1"

    var validation_warning:String = _validate_input()
    if(!validation_warning.is_empty()):
        GPM_UIOperations.create_warning_dialog(validation_warning, self).popup_centered()
        return
    
    var selected_files:Array = _package_content_display.get_all_selected()
    var config:GPM_PackageConfig = GPM_PackageConfig.new()
    config.contents = selected_files
    config.package_name = _package_name_input.text
    config.package_version = _package_version_input.text
    config.package_description = _package_description_input.text
    
    GPM_PackageOperations.export_package(config, _package_root_display_label.text, GodotPackageManager.loaded_config.package_source_locations[_package_source_dropdown.selected])
    pass