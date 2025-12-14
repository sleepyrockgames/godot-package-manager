class_name GPM_PackageConfig extends RefCounted

var package_name:String

var package_version:String

var package_description:String

const INVALID_CHARACTERS:Array[String] = ["/", "\"", "\'","`"]

# The contents (relative file paths) of this package
var contents:Array = []

func to_json()->String:
    # TODO(@sleepyrockgames)
    return ""
    pass

static func from_json(json:String)->GPM_PackageConfig:
    # TODO(@sleepyrockgames)
    return null