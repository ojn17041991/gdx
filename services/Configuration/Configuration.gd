class_name _configuration extends Node

const DELIMITER: String = ":"
const ERROR_COULD_NOT_READ_FILES: String = "Failed to read configuration files."
const ERROR_PROPERTY_NOT_FOUND: String = "Property at given path does not exist in project configuration."
const ERROR_INCORRECT_TYPE: String = "Property at given path was not of the type specified."

var _settings: Dictionary = {}

func _init() -> void:
	_load()

func Get(propertyName: String) -> Variant:
	return _recurse(_settings, propertyName.split(DELIMITER), 0)

func GetString(propertyName: String) -> String:
	var property = Get(propertyName)
	assert(typeof(property) == TYPE_STRING, ERROR_INCORRECT_TYPE)
	return property as String

func GetBoolean(propertyName: String) -> bool:
	var property = Get(propertyName)
	assert(typeof(property) == TYPE_BOOL, ERROR_INCORRECT_TYPE)
	return property as bool

func GetInt(propertyName: String) -> int:
	var property = Get(propertyName)
	assert([TYPE_INT, TYPE_FLOAT].has(typeof(property)), ERROR_INCORRECT_TYPE)
	return property as int

func GetFloat(propertyName: String) -> float:
	var property = Get(propertyName)
	assert([TYPE_INT, TYPE_FLOAT].has(typeof(property)), ERROR_INCORRECT_TYPE)
	return property as float

func GetDictionary(propertyName: String) -> Dictionary:
	var property = Get(propertyName)
	assert(typeof(property) == TYPE_DICTIONARY, ERROR_INCORRECT_TYPE)
	return property as Dictionary

func GetArray(propertyName: String) -> Array:
	var property = Get(propertyName)
	assert(typeof(property) == TYPE_ARRAY, ERROR_INCORRECT_TYPE)
	return property as Array

func Refresh() -> void:
	_settings.clear()
	_load()

func _load() -> void:
	# Inject the file reader and get the settings.
	var router: Router = Router.new()
	var filePath: String = router.BuildPath(
		"services/Configuration/Abstract/BaseConfigurationFileReader.gd"
	)
	var fileReader: BaseConfigurationFileReader = DependencyInjection.Create(filePath)
	var settingsResult: Result = fileReader.Read()
	assert(settingsResult.ResultType == ResultType.Ok, ERROR_COULD_NOT_READ_FILES)
	_settings = settingsResult.Data

func _recurse(settings: Dictionary, path: Array, idx: int) -> Variant:
	var propertyName: String = path[idx]
	assert(settings.has(propertyName), ERROR_PROPERTY_NOT_FOUND)
	if (idx < path.size() - 1):
		return _recurse(settings[propertyName], path, idx + 1)
	else:
		return settings[propertyName]
