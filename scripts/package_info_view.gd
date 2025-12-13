@tool
class_name GPM_PackageInfoView extends Control

static var INDENT_PX_PER_DIRECTORY_LEVEL:int = 25

@onready var name_label:Label = %PackageNameLabel
@onready var description:Label = %DescriptionLabel
@onready var file_tree:VBoxContainer = %CurrentPackageTree

const DIRECTORY_SEPARATOR:String = "/"

const FILE_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_file_tree_node.tscn")
const DIRECTORY_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_directory_tree_node.tscn")

## The map of full paths to the corresponding tree item
var file_item_map:Dictionary[String, GPM_FileTreeItem] = {}

## The map of a dir path to the direct children in that path
var file_item_direct_children:Dictionary[String, Array]

var ignore_extension_patterns:Array[String] = ["import", "guid", "uid"]

func _ready() -> void:
    for child in file_tree.get_children():
        child.queue_free()
    file_item_map.clear()
    build_tree_with_root_path("res://")

    print("\n - ".join(file_item_map.keys()))
    print(" ============================= " )
    print("\n - ".join(file_item_direct_children.keys()))
    pass

## Rebuilds the file tree with the provided root path
func build_tree_with_root_path(root_path:String)->void:
    for val in file_item_map.values():
        if(is_instance_valid(val)):
            val.queue_free()

    file_item_direct_children.clear()
    file_item_map.clear()
    create_new_directory_node(root_path, null, -1)
    pass

## Recursive function to build the file tree
func _build_tree(current_node:GPM_DirectoryTreeNode, directory_level:int)->void:
    var directories:Array[String] = []
    directories.append_array(DirAccess.get_directories_at(current_node.full_path))
    var files:Array[String] = []
    files.append_array(DirAccess.get_files_at(current_node.full_path))

    # print("Files: " + str(files.size()) + " dirs: " + str(directories.size()))
    var split = current_node.full_path.split(DIRECTORY_SEPARATOR)
    var dir_name = split[split.size()-1]

    var all_children:Array[String] = []
    all_children.append_array(directories)
    all_children.append_array(files)
    all_children.sort()

    # Don't include empty directories
    if(all_children.is_empty()):
        return
        
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
func create_new_file_node(file_name:String, parent_dir_node:GPM_DirectoryTreeNode, file_level:int):
    var new_child:= FILE_NODE_PREFAB.instantiate() as GPM_FileTreeItem
    
    file_tree.add_child(new_child)
    var full_path := parent_dir_node.full_path + DIRECTORY_SEPARATOR + file_name
    new_child.set_node_text(full_path)
    file_item_map[full_path] = new_child

    #update_child_map(parent_directory_path, new_child)
    parent_dir_node.add_tree_child(new_child)

    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    #new_child.state_updated.connect(on_state_update.bind(new_child.full_path, false))
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_dir_node:GPM_DirectoryTreeNode,  directory_level:int)->void:

    print("~~ Creating new directory node for " + new_directory_name)
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    
    
    var parent_path:String = ""
    if(is_instance_valid(parent_dir_node)):

        # Only add to the tree if *not* the root
        file_tree.add_child(new_child)

        parent_path = parent_dir_node.full_path
        if(!parent_path.ends_with("/")):
            parent_path += DIRECTORY_SEPARATOR

    var full_path := parent_path + new_directory_name
    new_child.set_node_text(full_path)

    if(is_instance_valid(parent_dir_node)):
        parent_dir_node.add_tree_child(new_child)
    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)

    #new_child.state_updated.connect(on_state_update.bind(new_child.full_path, true))
    #update_child_map(parent_directory_path, new_child)

    _build_tree(new_child, directory_level + 1)
    pass