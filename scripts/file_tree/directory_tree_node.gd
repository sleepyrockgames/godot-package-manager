@tool
class_name GPM_DirectoryTreeNode extends GPM_FileTreeItem

var child_nodes:Array[GPM_FileTreeItem]

func add_tree_child(new_child:GPM_FileTreeItem)->void:
    if(!child_nodes.has(new_child)):
        child_nodes.append(new_child)
        new_child._parent_directory = self

## Propogates the current state as required
func _propogate_state()->void:
    if( _current_state != GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED):
        recursive_set_child_state(_current_state)

    # Update ourselves and move up
    recalculate_state()

## Recalculates our own state, then notifies the parent to do the same
func recalculate_state()->void:
    _set_state(_calculate_folder_state_from_children())
    if(is_instance_valid(_parent_directory)):
        _parent_directory.recalculate_state()
    pass

## Calculates the folder state from the state of the direct children
func _calculate_folder_state_from_children()->GPM_FileTreeItem.FILE_SELECTION_STATE:
    var all_children_checked:bool = _all_children_match_state(child_nodes, GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED)
    var all_children_unchecked:bool = _all_children_match_state(child_nodes, GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED)

    if(all_children_checked):
        return GPM_FileTreeItem.FILE_SELECTION_STATE.SELECTED
    elif(all_children_unchecked):
        return GPM_FileTreeItem.FILE_SELECTION_STATE.UNSELECTED
    return GPM_FileTreeItem.FILE_SELECTION_STATE.MIXED
    pass

## Checks if all children of the parent dir match the target state
func _all_children_match_state(tree_children:Array[GPM_FileTreeItem], target_state:GPM_FileTreeItem.FILE_SELECTION_STATE)->bool:
    return tree_children.all(func(child:GPM_FileTreeItem): return child._current_state == target_state)
    pass

## Recursively set the state of any descendant files and folder
func recursive_set_child_state(new_state:GPM_FileTreeItem.FILE_SELECTION_STATE)->void:
    for child:GPM_FileTreeItem in child_nodes:
        child._set_state(new_state)
        if(child is GPM_DirectoryTreeNode):
            child._propogate_state()
    pass
