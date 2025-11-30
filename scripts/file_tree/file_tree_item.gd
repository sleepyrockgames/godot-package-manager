@abstract @tool
class_name GPM_FileTreeItem extends Control

## The name of the node (file or directory) this item represents
var node_name:String = ""

## The full path to the file this node represents, relative to the root directory
var full_path:String = ""

@export var label_node:Label
@export var indent_spacer:Control
@export var select_button:Button

const BUTTON_SIZE_PX:int = 15

func set_node_text(item_full_path:String)->void:
    full_path = item_full_path

    ## Extract the item name from the file path
    var split = full_path.split("/")
    node_name = split[split.size()-1]
    if(label_node != null):
        label_node.text = node_name
    pass

func _ready() -> void:
   select_button.custom_minimum_size = Vector2.ONE * min(size.y, BUTTON_SIZE_PX)
   pass

## Callback for when the item is toggled
func on_item_toggle(is_selected:bool)->void:

    # TODO: Implement me
    pass

## Sets the (horizontal) indent spacing
func set_indent_spacing(pixel_indent_horiz:int)->void:
    indent_spacer.custom_minimum_size = Vector2(pixel_indent_horiz, indent_spacer.custom_minimum_size.y)