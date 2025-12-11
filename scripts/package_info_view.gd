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
    build_tree_with_root_path("res://addons")

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
    build_tree(root_path, 0)
    pass

## Recursive function to build the file tree
func build_tree(current_node:String, directory_level:int)->void:
    var directories:Array[String] = []
    directories.append_array(DirAccess.get_directories_at(current_node))
    var files:Array[String] = []
    files.append_array(DirAccess.get_files_at(current_node))

    # print("Files: " + str(files.size()) + " dirs: " + str(directories.size()))
    var split = current_node.split(DIRECTORY_SEPARATOR)
    var dir_name = split[split.size()-1]

    var all_children:Array[String] = []
    all_children.append_array(directories)
    all_children.append_array(files)
    all_children.sort()

    # Don't include empty directories
    if(all_children.is_empty()):
        return

    # Handle special directories (e.g res://, user:// etc)
    if(current_node.ends_with(DIRECTORY_SEPARATOR + DIRECTORY_SEPARATOR)):
        current_node = current_node.replace(DIRECTORY_SEPARATOR + DIRECTORY_SEPARATOR, DIRECTORY_SEPARATOR)

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

## Callback handler for when a new button is selected
func on_state_update(new_item_state:GPM_FileTreeItem.FILE_SELECTION_STATE, full_item_path:String, is_directory:bool)->void:
    if(is_directory):
        handle_new_directory_state(new_item_state, full_item_path, [])
        pass
    else:
        handle_new_file_state(new_item_state, full_item_path, [])
        pass
    print(" -------------- ")
    pass

## Returns TRUE if the file at the given path should be ignored from the file selection
func should_ignore_file(file_name:String)->bool:
    return !ignore_extension_patterns.filter(
                    func(extension:String)->bool: return file_name.ends_with(extension))\
                    .is_empty()

## Handles the state change of a directory
func handle_new_directory_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE, full_item_path:String, visited:Array[String])->void:
    # Skip already updated paths
    if(visited.has(full_item_path)):
        return
    visited.append(full_item_path)

    if(new_state != GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED):
        recursive_set_child_state(new_state, full_item_path)

        # Update parents
        var parent_path:String = _get_parent_directory_path(full_item_path)
        if(file_item_map.has(parent_path)):
            var parent_node:GPM_DirectoryTreeNode = file_item_map[parent_path]
            parent_node._set_state(_calculate_folder_state_from_children(parent_path))
            handle_new_directory_state(parent_node.current_state, parent_path, visited)

    # Recalculate our state and move up a level to do the same
    else:
        var current_node:GPM_DirectoryTreeNode = file_item_map[full_item_path]
        current_node._set_state(_calculate_folder_state_from_children(full_item_path))
        var parent_path:String = _get_parent_directory_path(full_item_path)

        if(file_item_map.has(parent_path)):
            var parent_node:GPM_DirectoryTreeNode = file_item_map[parent_path]
            handle_new_directory_state(GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED, parent_path, visited)

        

    print(full_item_path + " changed to " + str(GPM_FileTreeItem.FILE_SELECTION_STATE.keys()[file_item_map[full_item_path].current_state]))
    pass

## Checks if all children of the parent dir match the target state
func _all_children_match_state(parent_dir_path:String, target_state:GPM_FileTreeItem.FILE_SELECTION_STATE)->bool:
    var children:Array = file_item_direct_children[parent_dir_path]
    return children.all(func(child:GPM_FileTreeItem): return child.current_state == target_state)
    pass

## Handles the state change of a file
func handle_new_file_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE, full_item_path:String, visited:Array[String])->void:

    if(visited.has(full_item_path)):
        return
    
    visited.push_back(full_item_path)

    var parent_dir_path := _get_parent_directory_path(full_item_path)
    # Probably hit the root of the files
    if(!file_item_map.has(parent_dir_path)):
        return

    var parent_node:GPM_FileTreeItem = file_item_map[parent_dir_path]
    handle_new_directory_state(GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED,parent_dir_path, visited)
    pass

## Calculates the folder state from the state of the direct children
func _calculate_folder_state_from_children(folder_path:String)->GPM_FileTreeItem.FILE_SELECTION_STATE:
    if(!file_item_direct_children.has(folder_path)):
        print("!! calcaulte folder state: dir not found- " + folder_path)
        return GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED
    
    var children:Array = file_item_direct_children[folder_path]

    var all_children_checked:bool = _all_children_match_state(folder_path, GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED)
    var all_children_unchecked:bool = _all_children_match_state(folder_path, GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)
    if(all_children_checked):
        return GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED
    elif(all_children_unchecked):
        return GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED
    return GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED
    pass

## Recursively set the state of any descendant files and folder
func recursive_set_child_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE, folder_dir:String)->void:
    var folder_node:GPM_DirectoryTreeNode = file_item_map[folder_dir]
    folder_node._set_state(new_state)

    

    for child:GPM_FileTreeItem in file_item_direct_children[folder_dir]:
        child._set_state(new_state)
        if(child is GPM_DirectoryTreeNode):
            recursive_set_child_state(new_state, child.full_path)
        pass

    pass

func _get_parent_directory_path(file_path:String)->String:
    var path_parts:= file_path.split(DIRECTORY_SEPARATOR)
    var parent_dir_path:String = DIRECTORY_SEPARATOR.join(path_parts.slice(0, path_parts.size() -1))
    return parent_dir_path
    pass

## Updates the child map with the new child
func update_child_map(parent_path:String, new_child:GPM_FileTreeItem)->void:
    if(!file_item_direct_children.has(parent_path)):
        file_item_direct_children[parent_path] = []
        print("added " + parent_path + " to child map")

    assert(!file_item_direct_children[parent_path].has(new_child), "Attempted to re-add a child to the parent map!!")
    file_item_direct_children[parent_path].append(new_child)

    pass

## Helper function to create a new file node
func create_new_file_node(file_name:String, parent_directory_path:String, file_level:int):
    var new_child:= FILE_NODE_PREFAB.instantiate() as GPM_FileTreeItem
    
    file_tree.add_child(new_child)
    var full_path := parent_directory_path + DIRECTORY_SEPARATOR + file_name
    new_child.set_node_text(full_path)
    file_item_map[full_path] = new_child

    update_child_map(parent_directory_path, new_child)

    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    new_child.state_updated.connect(on_state_update.bind(new_child.full_path, false))
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_directory_path:String,  directory_level:int)->void:

    print("~~ Creating new node for " + new_directory_name)
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    
    file_tree.add_child(new_child)
    var full_path := parent_directory_path + DIRECTORY_SEPARATOR + new_directory_name
    new_child.set_node_text(full_path)

    file_item_map[full_path] = new_child
    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)


    new_child.state_updated.connect(on_state_update.bind(new_child.full_path, true))
    update_child_map(parent_directory_path, new_child)
    build_tree(full_path, directory_level + 1)
    pass