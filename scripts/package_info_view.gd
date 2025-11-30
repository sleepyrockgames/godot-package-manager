@tool
class_name GPM_PackageInfoView extends Control

static var INDENT_PX_PER_DIRECTORY_LEVEL:int = 25

@onready var name_label:Label = %PackageNameLabel
@onready var description:Label = %DescriptionLabel
@onready var file_tree:VBoxContainer = %CurrentPackageTree

const FILE_NODE_PREFAB = preload("res://addons/package_manager/interfaces/gpm_file_tree_node.tscn")
const DIRECTORY_NODE_PREFAB = preload("res://addons/package_manager/interfaces/gpm_directory_tree_node.tscn")

func update_display(package_json:Dictionary)->void:
   #print("\n".join(build_tree(package_json[GPM.GPM_DATA_KEYS.ROOT_DIRECTORY], [])))
   #file_tree.create_item()

   pass

func _ready() -> void:
    #print("\n".join(build_tree("res://", [])))
    for child in file_tree.get_children():
        child.queue_free()
    build_tree("res://", 0)
    #file_tree.cell_selected.connect(on_cell_connect)
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
    #print(all_children)

    for child_item in all_children:
        # Handle Directory
        if(directories.has(child_item)):
            # Recurse
            # TODO: Add tooltip
           # print("recursing into " + current_node)
            create_new_directory_node(child_item, current_node, directory_level)

        # Handle Files
        elif(files.has(child_item)):
            create_new_file_node(child_item, current_node, directory_level)
            pass
    pass

## Helper function to create a new file node
func create_new_file_node(file_name:String, parent_directory_path:String, file_level:int):
    var new_child:= FILE_NODE_PREFAB.instantiate() as GPM_FileTreeItem
    
    file_tree.add_child(new_child)
    new_child.set_node_text(parent_directory_path + "/" + file_name)
    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_directory_path:String,  directory_level:int)->void:
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    
    file_tree.add_child(new_child)
    new_child.set_node_text(parent_directory_path + "/" + new_directory_name)
    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    build_tree(parent_directory_path + "/" + new_directory_name, directory_level + 1)
    pass