class_name GPM_FileHelpers extends Object

## Extracts the zip archive at [b]zip_path[/b] to [b]target_root_dir_path[/b]
static func extract_zip_to_path(zip_path:String, target_root_dir_path:String)->void:

	if(!FileAccess.file_exists(zip_path)):
		printerr("Zip directory at path " + zip_path + " doesn't exist!")
		return
	var reader:ZIPReader = ZIPReader.new()
	var error_code:int = reader.open(zip_path)

	if(error_code != OK):
		printerr("An error occured opening a zip archive: " + error_string(error_code))
		return

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.

	var target_root_global:String = ProjectSettings.globalize_path(target_root_dir_path)
	DirAccess.make_dir_recursive_absolute(target_root_global)
	var root_dir:DirAccess = DirAccess.open(target_root_global)

	if (DirAccess.get_open_error() != OK):
		printerr("An error occured opening the directory to unzip an archive to: " + error_string(DirAccess.get_open_error()))
		return

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with(GodotPackageManager.DIRECTORY_SEPARATOR):
			root_dir.make_dir_recursive(file_path)
			continue
		print("extracting: " + file_path + " to " + root_dir.get_current_dir().path_join(file_path))

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file: FileAccess = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		if (FileAccess.get_open_error() != OK):
			printerr("An error occured extracting a file from an archive: " + error_string(FileAccess.get_open_error()))
			return

		var buffer:PackedByteArray = reader.read_file(file_path)
		file.store_buffer(buffer)
		file.close()
	pass
