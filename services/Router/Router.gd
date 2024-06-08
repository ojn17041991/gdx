class_name Router extends Node

func GetRootPath() -> String:
	var path: String = get_script().resource_path
	var pathComponents: PackedStringArray = path.split('/')
	var numPathComponents: int = pathComponents.size()
	var rootPath: String = "res://"
	for pathComponentIdx: int in numPathComponents:
		if (pathComponentIdx < 2):
			continue
		if (pathComponentIdx > numPathComponents - 4):
			continue
		rootPath += pathComponents[pathComponentIdx] + "/"
	return rootPath

func BuildPath(pathSuffix: String) -> String:
	return GetRootPath() + pathSuffix
