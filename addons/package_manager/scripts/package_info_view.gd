@tool
class_name GPM_PackageInfoView extends Control

@onready var name_label:Label = %PackageNameLabel
@onready var description:Label = %DescriptionLabel
@onready var file_tree:Tree = %CurrentPackageTree

func update_display(package_json:Dictionary)->void:
   #print("\n".join(build_tree(package_json[GPM.GPM_DATA_KEYS.ROOT_DIRECTORY], [])))
   file_tree.create_item()
   pass

func _ready() -> void:
    #print("\n".join(build_tree("res://", [])))
    var root = file_tree.create_item()
    build_tree(root, "res://", [])
    root.set_text(0, "res://")
    pass

## Builds the tree, returning the root node for the directory
func build_tree(current_node:TreeItem, dir:String, visited:Array[String])->TreeItem:
    var directories:PackedStringArray = DirAccess.get_directories_at(dir)
    var files:PackedStringArray = DirAccess.get_files_at(dir)

    var split = dir.split("/")
    var dir_name = split[split.size()-1]
    current_node.set_text(0, dir_name +"/")

    # TODO: Add tooltip
    for file in files:
        #current.add_child(GPM_FileTreeNode.new.call(file))
        var new_child:TreeItem = current_node.create_child()
       
        new_child.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
        new_child.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        new_child.set_text(1, file)
        pass
   
    for child_dir in directories:
        print("recursing into " + dir)
        var new_dir_node = current_node.create_child()
        build_tree(new_dir_node, dir + "/" + child_dir, visited)
    
    return current_node
    pass