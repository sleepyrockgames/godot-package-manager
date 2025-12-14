@tool
class_name GPM_PackageManagerWindow extends Window

var settings_window_prefab:PackedScene = load("res://addons/godot-package-manager/interfaces/package_manager_settings.tscn")
var settings_window_instance:Window

var _new_package_dialog:PackedScene = load("res://addons/godot-package-manager/interfaces/gpm_new_package_window.tscn")
var _loaded_packages:Dictionary = {}

@export var _found_packages_list:VBoxContainer
@export var _no_packages_shown_view:Control
@export var _package_details_view:Control

@onready var _package_name_label:Label = %PackageNameLabel
@onready var _package_desc_label:Label = %PackageDescriptionLabel
@onready var _package_version_label:Label = %PackageVersionLabel
@onready var _package_files_view:GPM_PackageFileTreeDisplay = %PackageFileDetails


func _ready()->void:
    close_requested.connect(hide)
    %RefreshPackagesButton.pressed.connect(_refresh_package_list)
    %NewPackageButton.pressed.connect(show_create_package)
    %OpenGPMSettingsButton.pressed.connect(open_gpm_settings)
    
    _package_details_view.visible = false
    _no_packages_shown_view.visible = true
    _refresh_package_list()
    pass

func _reload_all_sources()->void:
    _loaded_packages.clear()
    # No sources to load
    if(GodotPackageManager.loaded_config.package_source_locations.is_empty()):
        return
    var all_sources:Array = GodotPackageManager.loaded_config.package_source_locations

    for source_path:String in all_sources:
        _loaded_packages.merge(GPM_PackageOperations.load_packages_in_dir(source_path))

    print("Loaded " + str(_loaded_packages.size()) + " packages!")
    pass

## Opens the settings dialog
func open_gpm_settings()->void:
    if(is_instance_valid(settings_window_instance) && GodotPackageManager.IS_DEBUG):
        remove_child(settings_window_instance)
        settings_window_instance.free()
        pass

    if(!is_instance_valid(settings_window_instance)):
        settings_window_instance = settings_window_prefab.instantiate()
        add_child(settings_window_instance)
    settings_window_instance.show()
    pass

## Shows the create package dialog
func show_create_package()->void:
    # TODO(@sleepyrockgames)
    var new_dialog_inst:Window = _new_package_dialog.instantiate()
    new_dialog_inst.close_requested.connect(new_dialog_inst.queue_free)

    add_child(new_dialog_inst)
    new_dialog_inst.popup_centered()
    pass

## Shows the details for the provided package
func show_package_details(package_path:String)->void:
    var config:GPM_PackageConfig = _loaded_packages[package_path]

    # Do UI setup
    _package_name_label.text = config.package_name
    _package_desc_label.text = config.package_description
    _package_version_label.text = config.package_version

    # TODO(@sleepyrockgames): Update this to filter out what's not listed in the package info.
    # This currently pulls directly from the file tree
    _package_files_view.build_tree_with_root_path(GPM_PackageOperations._get_parent_directory_abs_path(package_path))

    _package_details_view.visible = true
    _no_packages_shown_view.visible = false
    pass

## Refreshes the package list
func _refresh_package_list()->void:
    _reload_all_sources()
    for child:Node in _found_packages_list.get_children():
        child.queue_free()

    for package_path:String in _loaded_packages.keys():
        var button:Button = Button.new()
        button.text = _loaded_packages[package_path].package_name
        _found_packages_list.add_child(button)
        button.pressed.connect(show_package_details.bind(package_path))
        pass
    pass
