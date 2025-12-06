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
    # TODO: Handle button changed state
    if(is_directory):
        handle_new_directory_state(new_item_state, full_item_path)
        pass
    else:
        handle_new_file_state(new_item_state, full_item_path)
        pass
    pass

## Returns TRUE if the file at the given path should be ignored from the file selection
func should_ignore_file(file_name:String)->bool:
    return !ignore_extension_patterns.filter(
                    func(extension:String)->bool: return file_name.ends_with(extension))\
                    .is_empty()

## Handles the state change of a directory
func handle_new_directory_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE, full_item_path:String)->void:
    print("handling state change of " + full_item_path)
    if(new_state != GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED):
        ## For both selected and unselected, recursively update any children to match the same state
        var child_items:Array = file_item_direct_children[full_item_path + DIRECTORY_SEPARATOR]
        var new_child_state:GPM_FileTreeItem.FILE_SELECTION_STATE = new_state
        for child:GPM_FileTreeItem in child_items:
                child._set_state(new_child_state)
                # Recurse to child directories
                if(child is GPM_DirectoryTreeNode):
                    handle_new_directory_state(child.current_state, child.full_path)


    # For unselected, update the parent to mixed
    if(new_state == GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED):
        var path_parts:= full_item_path.split(DIRECTORY_SEPARATOR)
        var parent_dir_path:String = DIRECTORY_SEPARATOR.join(path_parts.slice(0, path_parts.size() -1))
        if(!file_item_map.has(parent_dir_path)):
            return
            
        # If our parent folder wasn't already deselected, set it to mixed
        var parent_node:GPM_FileTreeItem = file_item_map[parent_dir_path]
        if(parent_node.current_state != GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED):
            parent_node._set_state(GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED)
            handle_new_directory_state(parent_node.current_state, parent_node.full_path)
        pass


    if(new_state == GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED):
        # If we have no children, unselect ourselves
        if(!file_item_direct_children.has(full_item_path + DIRECTORY_SEPARATOR)):
            file_item_map[full_item_path]._set_state(GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)
            return

        # Propogate upwards
        var path_parts:= full_item_path.split(DIRECTORY_SEPARATOR)
        var parent_dir_path:String = DIRECTORY_SEPARATOR.join(path_parts.slice(0, path_parts.size() -1))
        # Probably hit the root of the files
        if(!file_item_map.has(parent_dir_path)):
            return
            
        var parent_node:GPM_FileTreeItem = file_item_map[parent_dir_path]
        
        ## All siblings are in the same state
        if(_all_children_match_state(full_item_path, GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)):
            file_item_map[full_item_path]._set_state(GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)
            
            parent_node._set_state(GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)
            #handle_new_directory_state(parent_node.current_state, parent_node.full_path)
        #else:
            #parent_node._set_state(GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED)

        #handle_new_directory_state(parent_node.current_state, parent_node.full_path)
            
           
    pass


func _all_children_match_state(parent_dir_path:String, target_state:GPM_FileTreeItem.FILE_SELECTION_STATE)->bool:
    # Otherwise, if all children are unselected, deselect self and propogate upwards
    var children:Array = file_item_direct_children[parent_dir_path + DIRECTORY_SEPARATOR]
       
    var matched_state:= GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED
    return children.all(func(child:GPM_FileTreeItem): return child.current_state == matched_state)
    pass

## Handles the state change of a file
func handle_new_file_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE, full_item_path:String)->void:
    if(new_state == GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED):
        # Deselect self and mark parent directory as mixed
        pass
    elif(new_state == GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED):
        # Mark self as selected and check if the parent file has all children included
        pass

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
    var full_path := parent_directory_path + "/" + file_name
    new_child.set_node_text(full_path)
    file_item_map[full_path] = new_child

    update_child_map(parent_directory_path + "/", new_child)

    new_child.set_indent_spacing(file_level * INDENT_PX_PER_DIRECTORY_LEVEL)
    new_child.state_updated.connect(on_state_update.bind(new_child.full_path, false))
    pass

## Helper function to create a new directory node
func create_new_directory_node(new_directory_name:String, parent_directory_path:String,  directory_level:int)->void:
    var new_child:= DIRECTORY_NODE_PREFAB.instantiate() as GPM_DirectoryTreeNode
    
    file_tree.add_child(new_child)
    var full_path := parent_directory_path + "/" + new_directory_name
    new_child.set_node_text(full_path)

    file_item_map[full_path] = new_child
    new_child.set_indent_spacing(directory_level * INDENT_PX_PER_DIRECTORY_LEVEL)


    new_child.state_updated.connect(on_state_update.bind(new_child.full_path, true))
    update_child_map(parent_directory_path + "/", new_child)
    build_tree(full_path, directory_level + 1)
    pass