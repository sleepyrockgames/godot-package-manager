@tool
class_name GPM_PackageManagerWindow extends Window

var settings_window_prefab:PackedScene = load("res://addons/godot-package-manager/interfaces/package_manager_settings.tscn")
var settings_window_instance:Window

var _new_package_dialog:PackedScene = load("res://addons/godot-package-manager/interfaces/gpm_new_package_window.tscn")

func _ready()->void:
    close_requested.connect(hide)
    %RefreshPackagesButton.pressed.connect(refresh_package_list)
    %NewPackageButton.pressed.connect(show_create_package)
    %OpenGPMSettingsButton.pressed.connect(open_gpm_settings)
    pass

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

## Refreshes the package list
func refresh_package_list()->void:
    # TODO(@sleepyrockgames)
    pass
