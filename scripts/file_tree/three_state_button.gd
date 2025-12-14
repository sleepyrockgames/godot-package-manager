@tool class_name GPM_ThreeStateButton extends Button

var selected_icon:Texture2D = preload("res://addons/godot-package-manager/assets/selected.png")
var unselected_icon:Texture2D = preload("res://addons/godot-package-manager/assets/icon_unselected.png")
var mixed_icon:Texture2D = preload("res://addons/godot-package-manager/assets/partially_selected.png")

@export var icon_rect:TextureRect

## Updates the selected icon
func update_icon_for_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE)->void:
    match(new_state):
        GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED:
            icon_rect.texture = selected_icon
            pass
        GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED:
            icon_rect.texture = unselected_icon
            pass
        GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED:
            icon_rect.texture = mixed_icon
            pass

    pass