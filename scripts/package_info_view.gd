@tool
class_name GPM_PackageInfoView extends Control

@onready var _package_name_label:Label = %PackageNameLabel
@onready var _package_desc_label:Label = %PackageDescriptionLabel
@onready var _package_version_label:Label = %PackageVersionLabel

@export var _import_shown_package_button:Button

var _shown_config_path:String

signal import_package_pressed()

func _ready() -> void:
    _import_shown_package_button.pressed.connect(func(): import_package_pressed.emit(_shown_config_path))

func show_config(config:GPM_PackageConfig, config_path:String)->void:
    _package_name_label.text = config.package_name
    _package_desc_label.text = config.package_description
    _package_version_label.text = config.package_version
    
    _shown_config_path = config_path
    pass