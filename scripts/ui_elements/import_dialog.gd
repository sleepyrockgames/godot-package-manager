@tool
class_name GPM_ImportDialog extends Window

@export var _cancel_button: Button
@export var _confirm_button: Button
@export var _set_import_location_button: Button

@export var _import_location_path_label: LineEdit
@export var _package_name_label: LineEdit

var _package_config: GPM_PackageConfig
var _root_package_path:String 

func _ready() -> void:
    close_requested.connect(hide)
    _cancel_button.pressed.connect(on_cancel)
    _confirm_button.pressed.connect(_on_confirm_import)
    _set_import_location_button.pressed.connect(_on_open_import_location_selection)

# Sets the package that's being imported
func set_imported_package(package_config: GPM_PackageConfig, package_source_path:String) -> void:
    _package_config = package_config
    _package_name_label.text = package_config.package_name
    _import_location_path_label.text = ""
    _root_package_path = package_source_path
    pass

func _on_open_import_location_selection() -> void:
    var new_file_dialog: FileDialog = FileDialog.new()
    add_child(new_file_dialog)

    new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    new_file_dialog.access = FileDialog.ACCESS_RESOURCES
    
    new_file_dialog.dir_selected.connect(_on_location_selected, CONNECT_ONE_SHOT)

    new_file_dialog.popup_centered()
    new_file_dialog.close_requested.connect(new_file_dialog.queue_free)
    pass

func _on_location_selected(path: String) -> void:
    _import_location_path_label.text = path
    pass

## Callback for when the user confirms the import
func _on_confirm_import() -> void:
    var import_location: String = _import_location_path_label.text

    # Show error message if no import location has been selected
    if (import_location.is_empty()):
        var dialog:Window = GPM_UIOperations.create_warning_dialog("No import location selected!", self)
        dialog.popup_centered()
        return

    print(_package_config.to_json())
    # Do import stuff
    var err:int = GPM_PackageOperations.import_package(_root_package_path, _package_config, import_location)

    var result_message:String = "Package imported successfully!"
    if(err != OK):
        result_message = "An error occurred while importing the package: " + error_string(err)
        pass
    var dialog:Window = GPM_UIOperations.create_warning_dialog(result_message, self)

    if(err == OK):
        # On a SUCCESSFUL import, close this dialog as well
        dialog.close_requested.connect(func():close_requested.emit.call_deferred())
    dialog.popup_centered()
    pass

func on_cancel() -> void:
    close_requested.emit()
    pass