@tool
class_name GPM_PackageManagerWindow extends Window

func _ready()->void:
    close_requested.connect(hide)
    %RefreshPackagesButton.pressed.connect(refresh_package_list)
    %NewPackageButton.pressed.connect(show_create_package)
    pass

## Shows the create package dialog
func show_create_package()->void:
    # TODO
    pass

## Refreshes the package list
func refresh_package_list()->void:
    # TODO
    pass
