class_name GPM_FileTreeNode extends TreeItem

var label:String = ""
func _init(label:String) -> void:
    self.label = label
    pass

func _ready():
    set_text(0, label)
    pass