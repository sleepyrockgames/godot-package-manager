@tool class_name GPM_ThreeStateButton extends Button

enum BUTTON_STATE {SELECTED, UNSELECTED, MIXED}

var selected_icon:Texture2D = preload("res://addons/godot-package-manager/assets/selected.png")
var unselected_icon:Texture2D = preload("res://addons/godot-package-manager/assets/icon_unselected.png")
var mixed_icon:Texture2D = preload("res://addons/godot-package-manager/assets/partially_selected.png")

var current_state:BUTTON_STATE = BUTTON_STATE.UNSELECTED
@onready var icon_rect:TextureRect = get_node("./Icon") as TextureRect

func _ready() -> void:
    pressed.connect(on_press)
    update_icon()
    pass

## Callback handler for when this button is pressed
func on_press()->void:
    if(current_state == BUTTON_STATE.UNSELECTED):
        current_state = BUTTON_STATE.SELECTED
        button_pressed = true
    #elif(current_state == BUTTON_STATE.SELECTED):
    #    current_state = BUTTON_STATE.MIXED
    else:
       current_state = BUTTON_STATE.UNSELECTED
       button_pressed = false
    
    update_icon()
    pass

## Updates the selected icon
func update_icon()->void:

    match(current_state):
        BUTTON_STATE.SELECTED:
            icon_rect.texture = selected_icon
            pass
        BUTTON_STATE.UNSELECTED:
            icon_rect.texture = unselected_icon
            pass
        BUTTON_STATE.MIXED:
            icon_rect.texture = mixed_icon
            pass

    pass