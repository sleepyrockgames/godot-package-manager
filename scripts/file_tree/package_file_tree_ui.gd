@tool
class_name GPM_PackageFileTreeDisplay extends Control

static var INDENT_PX_PER_DIRECTORY_LEVEL:int = 25


const FILE_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_file_tree_node.tscn")
const DIRECTORY_NODE_PREFAB = preload("res://addons/godot-package-manager/interfaces/gpm_directory_tree_node.tscn")

@onready var file_tree:VBoxContainer = get_node("MarginContainer/ScrollContainer/MarginContainer/PackageTree")

## The map of full paths to the corresponding tree item
var file_item_map:Dictionary[String, GPM_FileTreeItem] = {}
var ignore_extension_patterns:Array[String] = ["import", "guid", "uid"]


func _init_display()->void:
    for child in file_tree.get_children():
        child.queue_free()

    for val in file_item_map.values():
        if(is_instance_valid(val)):
            val.queue_free()

    file_item_map.clear()

## Get all selected files in the file tree
func get_all_selected()->Array[String]:
    return file_item_map.keys().filter(func(key): return  file_item_map[key] is GPM_FileTreeNode && file_item_map[key]._current_state == GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED)
    pass

## Sets whether the user can modify the file states (i.e. if it's read only)
func set_is_read_only(is_read_only:bool)->void:
    for item:GPM_FileTreeItem in file_item_map.values():
        item.is_view_only = is_read_only

func build_tree_from_file_list(file_paths:Array)->void:
    _init_display()

    var root = GPM_DirectoryTreeNode.new()
    # Build a 'fake' root 
    root.full_path = ""
    file_item_map[""] = root

    for path:String in file_paths:
        var path_parts:Array = path.split(GodotPackageManager.DIRECTORY_SEPARATOR)

        # Essentially a "make dir recursive" but for the file tree display
        var incremental_path = ""
        var parent_dir_path:String = ""
        for idx in range(0, path_parts.size()):
            var current_path:String = incremental_path + GodotPackageManager.DIRECTORY_SEPARATOR + path_parts[idx]
            #print("at: " + current_path)

            var parent_node:GPM_DirectoryTreeNode = null
            if(file_item_map.has(incremental_path)):
                parent_node = file_item_map[incremental_path]

            if(idx == path_parts.size()-1):
                # At file
                create_new_file_node(path_parts.back(), parent_node, path_parts.size()-1)
                continue
                pass

            if(!file_item_map.has(current_path)):
                create_new_directory_node(path_parts[idx], parent_node, idx)

            incremental_path = current_path
            pass

        #print("--------------")
        #print("")
        pass
    pass

## Rebuilds the file tree with the provided root path
func build_tree_with_root_path(root_path:String)->void:
    _init_display()
    _build_tree_from_file_system(create_new_directory_node(root_path, null, -1),0)
    pass

## Recursive function to build the file tree
func _build_tree_from_file_system(current_node:GPM_DirectoryTreeNode, directory_level:int)->void:
    var directories:Array[String] = []
    directories.append_array(DirAccess.get_directories_at(current_node.full_path))
    var files:Array[String] = []
    files.append_array(DirAccess.get_files_at(current_node.full_path))

    # print("Files: " + str(files.size()) + " dirs: " + str(directories.size()))
    var split = current_node.full_path.split(GodotPackageManager.DIRECTORY_SEPARATOR)
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
            # Recurse
            _build_tree_from_file_system(create_new_directory_node(child_item, current_node, directory_level), directory_level + 1)
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
    #print(parent_dir_node)
    var parent_path:String = ""
    if(parent_dir_node != null):
        parent_path = parent_dir_node.full_path + GodotPackageManager.DIRECTORY_SEPARATOR

    var full_path := parent_path + file_name
    new_child.set_node_text(full_path)
    file_item_map[full_path] = new_child

    #update_child_map(parent_directory_path, new_child)
    if(is_instance_valid(parent_dir_node)):
        parent_dir_node.add_tree_child(new_child)

    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    #new_child.state_updated.connect(on_state_update.bind(new_child.full_path, false))
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_dir_node:GPM_DirectoryTreeNode,  directory_level:int)->GPM_DirectoryTreeNode:
   # print("~~ Creating new directory node for " + new_directory_name)
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    var parent_path:String = ""
    if(is_instance_valid(parent_dir_node)):
        # Only add to the tree if *not* the root
        file_tree.add_child(new_child)
        #print("added child to tree")

        parent_path = parent_dir_node.full_path
        if(!parent_path.ends_with("/")):
            parent_path += GodotPackageManager.DIRECTORY_SEPARATOR

    var full_path := parent_path + new_directory_name
    new_child.set_node_text(full_path)

    if(is_instance_valid(parent_dir_node)):
        parent_dir_node.add_tree_child(new_child)

    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    file_item_map[full_path] = new_child
    return new_child
    pass