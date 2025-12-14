@tool
class_name GPM_ConfigSourceUI extends Control

@export var label_node:LineEdit
@export var remove_button:Button

signal remove_requested()

func _ready():
    remove_button.pressed.connect(func():remove_requested.emit())
    pass

