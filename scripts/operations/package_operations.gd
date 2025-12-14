@tool
class_name GPM_PackageOperations extends Object

static func export_package(config:GPM_PackageConfig, source_root_directory:String, package_source_path:String)->void:
    var temp_dir:DirAccess = DirAccess.open(package_source_path)

    if(temp_dir == null):
        printerr("Failed to open package export destination directory: " + error_string(DirAccess.get_open_error()))
        return

    var package_dir_name:String = config.package_name.to_lower().trim_prefix(" ").trim_suffix(" ").replace(" ", "_")
    var full_final_path:String = ProjectSettings.globalize_path(package_source_path + GodotPackageManager.DIRECTORY_SEPARATOR + package_dir_name)
    
    var relative_contents:Array[String] = []
    ## Copy all files to the temp dir
    for path:String in config.contents:
        var path_in_folder:String = path.replace(source_root_directory + GodotPackageManager.DIRECTORY_SEPARATOR,"")

        relative_contents.append(path_in_folder)
        # Update the contents with the relative directory
        var copied_path:String = full_final_path + GodotPackageManager.DIRECTORY_SEPARATOR + path_in_folder

        # Ensure the directory exists
        var copied_dir:String = _get_parent_directory_abs_path(copied_path)
        if(!DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(copied_dir))):
            DirAccess.make_dir_recursive_absolute(copied_dir)
            pass

        temp_dir.copy(path, copied_path)
        pass

    config.contents = relative_contents

    # Create package info
    var package_info_content:String = config.to_json()
    var info_file_path:String = full_final_path + GodotPackageManager.DIRECTORY_SEPARATOR + "info.gpi"
    var info_file:FileAccess = FileAccess.open(info_file_path, FileAccess.WRITE)
    if(info_file == null):
        printerr("Error writing package info file for " + config.package_name + ": " + error_string(FileAccess.get_open_error()))
        return
    info_file.store_string(package_info_content)
    info_file.close()
    
    pass

## Helper function to get the parent directory given the target path
static func _get_parent_directory_abs_path(full_path:String)->String:
   var parts = full_path.split(GodotPackageManager.DIRECTORY_SEPARATOR)
   var arr = []
   arr.append_array(parts)
   return GodotPackageManager.DIRECTORY_SEPARATOR.join(arr.slice(0, arr.size()-1))