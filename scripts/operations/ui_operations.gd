class_name GPM_UIOperations extends Object

static func create_warning_dialog(message:String, parent:Node)->AcceptDialog:
    var confirm_dialog:AcceptDialog = AcceptDialog.new()
    confirm_dialog.dialog_text = message
    confirm_dialog.ok_button_text = "Okay"
    parent.add_child(confirm_dialog)
    confirm_dialog.close_requested.connect(func():confirm_dialog.queue_free())
    return confirm_dialog
    pass
