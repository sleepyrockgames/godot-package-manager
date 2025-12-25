@tool
class_name GPM_PackageInfoView extends Control

@onready var _package_name_label:Label = %PackageNameLabel
@onready var _package_desc_label:Label = %PackageDescriptionLabel
@onready var _package_version_label:Label = %PackageVersionLabel


func show_config(config:GPM_PackageConfig)->void:
    # Do UI setup
    _package_name_label.text = config.package_name
    _package_desc_label.text = config.package_description
    _package_version_label.text = config.package_version

    pass