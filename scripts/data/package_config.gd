class_name GPM_PackageConfig extends RefCounted

const PACKAGE_NAME_KEY:String = "packageName"
var package_name:String

const PACKAGE_VERSION_KEY:String = "packageVersion"
var package_version:String

const PACKAGE_DESC_KEY:String = "packageDescription"
var package_description:String

## Invalid characters for text fields
const INVALID_CHARACTERS:Array[String] = ["/", "\"", "\'","`"]

const PACKAGE_CONTENTS_KEY:String = "packageContents"
# The contents (relative file paths) of this package
var contents:Array = []

func to_json()->String:
    var json:Dictionary = {}
    json[PACKAGE_NAME_KEY] = package_name
    json[PACKAGE_VERSION_KEY] = package_version
    json[PACKAGE_DESC_KEY] = package_description
    json[PACKAGE_CONTENTS_KEY] = contents
    return JSON.stringify(json," ")

static func from_json(json:String)->GPM_PackageConfig:
    var parsed:Dictionary = JSON.parse_string(json)
    var built:GPM_PackageConfig = GPM_PackageConfig.new()
    built.package_name = parsed[PACKAGE_NAME_KEY]
    built.package_version = parsed[PACKAGE_VERSION_KEY]
    built.package_description = parsed[PACKAGE_DESC_KEY]
    built.contents = parsed[PACKAGE_CONTENTS_KEY]
    return built