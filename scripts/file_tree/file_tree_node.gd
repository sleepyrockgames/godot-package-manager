@tool
class_name GPM_FileTreeNode extends GPM_FileTreeItem


func _propogate_state()->void:
    if(is_instance_valid(_parent_directory)):
        _parent_directory.recalculate_state()
        #_parent_directory._propogate_state()
    pass