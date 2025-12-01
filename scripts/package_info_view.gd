@tool
class_name GPM_PackageInfoView extends Control

static var INDENT_PX_PER_DIRECTORY_LEVEL:int = 25

@onready var name_label:Label = %PackageNameLabel
@onready var description:Label = %DescriptionLabel
@onready var file_tree:VBoxContainer = %CurrentPackageTree

const FILE_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_file_tree_node.tscn")
const DIRECTORY_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_directory_tree_node.tscn")

## The map of full paths to the corresponding tree item
var file_item_map:Dictionary[String, GPM_FileTreeItem] = {}

var ignore_extension_patterns:Array[String] = ["import", "guid", "uid"]

func _ready() -> void:
    for child in file_tree.get_children():
        child.queue_free()
    file_item_map.clear()
    build_tree("res://", 0)
    pass

## Builds the tree, returning the root node for the directory
func build_tree(current_node:String, directory_level:int)->void:

    var directories:Array[String] = []
    directories.append_array(DirAccess.get_directories_at(current_node))
    var files:Array[String] = []
    files.append_array(DirAccess.get_files_at(current_node))

    # print("Files: " + str(files.size()) + " dirs: " + str(directories.size()))
    var split = current_node.split("/")
    var dir_name = split[split.size()-1]

    var all_children:Array[String] = []
    all_children.append_array(directories)
    all_children.append_array(files)
    all_children.sort()

    for child_item in all_children:
        # Ignore if it matches a filter extension
        
        if(should_ignore_file(child_item)):
            continue

        # Handle Directory
        if(directories.has(child_item)):
            create_new_directory_node(child_item, current_node, directory_level)
            pass

        # Handle Files
        elif(files.has(child_item)):
            create_new_file_node(child_item, current_node, directory_level)
            pass
    pass

## Returns TRUE if the file at the given path should be ignored from the file selection
func should_ignore_file(file_name:String)->bool:
    return !ignore_extension_patterns.filter(
                    func(extension:String)->bool: return file_name.ends_with(extension))\
                    .is_empty()

## Helper function to create a new file node
func create_new_file_node(file_name:String, parent_directory_path:String, file_level:int):
    var new_child:= FILE_NODE_PREFAB.instantiate() as GPM_FileTreeItem
    
    file_tree.add_child(new_child)
    var full_path := parent_directory_path + "/" + file_name
    new_child.set_node_text(full_path)
    file_item_map[full_path] = new_child
    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_directory_path:String,  directory_level:int)->void:
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    
    file_tree.add_child(new_child)
    var full_path := parent_directory_path + "/" + new_directory_name
    new_child.set_node_text(full_path)

    file_item_map[full_path] = new_child
    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    build_tree(full_path, directory_level + 1)
    pass