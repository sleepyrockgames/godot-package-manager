@tool
class_name GPM_DirectoryTreeNode extends GPM_FileTreeItem

var child_nodes:Array[GPM_FileTreeItem]


func add_tree_child(new_child:GPM_FileTreeItem)->void:
    if(!child_nodes.has(new_child)):
        child_nodes.append(new_child)