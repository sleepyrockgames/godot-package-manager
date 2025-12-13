class_name GPM_PackageManagerConfig extends RefCounted

var config_file_location:String
const CONFIG_FILE_LOCATION_KEY = "configFileLocation"

# Converts the settings object to a JSON string
func to_json()->String:
    var json_dict:Dictionary = {}
    json_dict[CONFIG_FILE_LOCATION_KEY] = config_file_location

    return JSON.stringify(json_dict)
    pass

## Parses the settings object from a JSON string
static func from_json(json_string:String)->GPM_PackageManagerConfig:
    
    var parsed:Dictionary = JSON.parse_string(json_string)
    var new_config:GPM_PackageManagerConfig = GPM_PackageManagerConfig.new()
    new_config.config_file_location = parsed[CONFIG_FILE_LOCATION_KEY]

    return new_config
    pass