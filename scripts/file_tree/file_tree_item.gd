@abstract @tool
class_name GPM_FileTreeItem extends Control

## The name of the node (file or directory) this item represents
var node_name:String = ""

## The full path to the file this node represents, relative to the root directory
var full_path:String = ""

@export var label_node:Label
@export var indent_spacer:Control
@export var select_button:GPM_ThreeStateButton

## True if the user CAN'T change the state (i.e. it's read-only)
var is_view_only:bool = true

var _parent_directory:GPM_DirectoryTreeNode

enum FILE_SELECTION_STATE {SELECTED, UNSELECTED, MIXED}
var _current_state:FILE_SELECTION_STATE = FILE_SELECTION_STATE.UNSELECTED

signal state_updated(new_state:FILE_SELECTION_STATE)

const BUTTON_SIZE_PX:int = 15

func _ready() -> void:
   select_button.custom_minimum_size = Vector2.ONE * min(size.y, BUTTON_SIZE_PX)
   select_button.pressed.connect(on_item_toggle)
   pass

func set_parent_directory(dir:GPM_DirectoryTreeNode)->void:
    _parent_directory = dir

func get_parent_directory()->GPM_DirectoryTreeNode:
    return _parent_directory

#region UI

func set_node_text(item_full_path:String)->void:
    full_path = item_full_path

    ## Extract the item name from the file path
    var split = full_path.split(GPM_PackageFileTreeDisplay.DIRECTORY_SEPARATOR)
    node_name = split[split.size()-1]
    if(label_node != null):
        label_node.text = node_name
        if(self is GPM_DirectoryTreeNode):
            label_node.text += GPM_PackageFileTreeDisplay.DIRECTORY_SEPARATOR
    pass

## Set whether the selection of the file node can be toggled
func set_selectable(is_selectable:bool)->void:
    select_button.disabled = !is_selectable

## Callback for when the item is toggled
func on_item_toggle()->void:
    if(is_view_only):
        return

    if(_current_state == FILE_SELECTION_STATE.UNSELECTED):
        _set_state(FILE_SELECTION_STATE.SELECTED)
    else:
      _set_state(FILE_SELECTION_STATE.UNSELECTED)

    _propogate_state()
    pass

func _propogate_state()->void:
    printerr("!! DEFAULT PROPOGATE STATE WAS CALLED !!")
    pass

## Sets the state [i]WITHOUT[/i] firing an updatee
func _set_state(new_state:FILE_SELECTION_STATE)->void:
    _current_state = new_state
    select_button.update_icon_for_state(_current_state)
    pass

## Sets the (horizontal) indent spacing
func set_indent_spacing(pixel_indent_horiz:int)->void:
    indent_spacer.custom_minimum_size = Vector2(pixel_indent_horiz, indent_spacer.custom_minimum_size.y)

#endregion