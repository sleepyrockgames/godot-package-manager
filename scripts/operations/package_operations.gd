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
	var info_file_path:String = full_final_path + GodotPackageManager.DIRECTORY_SEPARATOR + "info" + GodotPackageManager.PM_PACKAGE_INFO_EXT
	var info_file:FileAccess = FileAccess.open(info_file_path, FileAccess.WRITE)
	if(info_file == null):
		printerr("Error writing package info file for " + config.package_name + ": " + error_string(FileAccess.get_open_error()))
		return
	info_file.store_string(package_info_content)
	info_file.close()
	
	pass

## Recursively scans the given directory for packages
static func _scan_for_packages(root_directory_abs_path:String, visited_dirs:Array[String])->Array:
	#print(root_directory_abs_path)
	if(visited_dirs.has(root_directory_abs_path)):
		return []
	visited_dirs.append(root_directory_abs_path)

	var packages_in_dir:Array = []
	packages_in_dir.append_array(DirAccess.get_files_at(root_directory_abs_path))

	# Remove any non-info files and convert the name to the full path to the file
	packages_in_dir = packages_in_dir.filter(func(file:String): return file.ends_with(GodotPackageManager.PM_PACKAGE_INFO_EXT))\
		.map(func(file_name): return root_directory_abs_path + GodotPackageManager.DIRECTORY_SEPARATOR + file_name)
   # print(packages_in_dir)

	for folder_path:String in DirAccess.get_directories_at(root_directory_abs_path):
		packages_in_dir.append_array(_scan_for_packages(root_directory_abs_path + GodotPackageManager.DIRECTORY_SEPARATOR + folder_path, visited_dirs))
		pass

	return packages_in_dir
	pass

## Loads all the packages present in the given directory (or its subdirectories), 
## mapping the full path to the config file to it's loaded config object
static func load_packages_in_dir(root_dir:String)->Dictionary:
	var loaded_packages:Dictionary = {}
	var package_paths:Array = _scan_for_packages(ProjectSettings.globalize_path(root_dir), [])
	
	for package_path:String in package_paths:
		var loaded_package_file:FileAccess = FileAccess.open(package_path, FileAccess.READ)
		if(loaded_package_file == null):
			printerr("Failed to load package information at " + package_path + ": " + error_string(FileAccess.get_open_error()))
			continue
		var file_contents:String = loaded_package_file.get_as_text()
		loaded_package_file.close()
		var config:GPM_PackageConfig = GPM_PackageConfig.from_json(file_contents)
		loaded_packages[package_path] = config

	return loaded_packages
	pass

## Performs the process of importing the package described in the [b]package_info_location[/b] config file to the [b]import_location[b]
static func import_package(package_info_location:String, package_config:GPM_PackageConfig, import_location:String)->int:
	var root_source_folder:String = _get_parent_directory_abs_path(package_info_location)

	for rel_file_path:String in package_config.contents:
		var full_from_location:String = root_source_folder + GodotPackageManager.DIRECTORY_SEPARATOR + rel_file_path
		var full_to_location:String = import_location + GodotPackageManager.DIRECTORY_SEPARATOR + package_config.package_name + GodotPackageManager.DIRECTORY_SEPARATOR + rel_file_path

		var abs_import_loc:String = ProjectSettings.globalize_path(full_to_location)
		var abs_import_directory:String = ProjectSettings.globalize_path(import_location + GodotPackageManager.DIRECTORY_SEPARATOR + package_config.package_name)

		print("copying from " + full_from_location + " to " + full_to_location)
		var err =  DirAccess.make_dir_recursive_absolute(_get_parent_directory_abs_path(abs_import_loc))
		if(err != OK):
			DirAccess.remove_absolute(abs_import_directory) # Cleanup
			return err

		err = DirAccess.copy_absolute(full_from_location, abs_import_loc)
		if(err != OK):
			DirAccess.remove_absolute(abs_import_directory) # Cleanup
			return err
		pass

	var fs = EditorInterface.get_resource_filesystem()
	if(!fs.is_scanning()):
		fs.scan()
		pass

	return OK
	pass

## Helper function to get the parent directory given the target path
static func _get_parent_directory_abs_path(full_path:String)->String:
	var parts = full_path.split(GodotPackageManager.DIRECTORY_SEPARATOR)
	var arr = []
	arr.append_array(parts)
	return GodotPackageManager.DIRECTORY_SEPARATOR.join(arr.slice(0, arr.size()-1))